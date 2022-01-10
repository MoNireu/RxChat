//
//  ChatRoomViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/11/26.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Action

class ChatRoomViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: ChatRoomViewModel!
    
    let MAX_LINE: Int = 5
    let BOTTOM_BAR_DEFAULT_HEIGHT: CGFloat = 84
    let CORNER_RADIUS_VALUE: Float = 0.02

    
    @IBOutlet weak var contextTextView: UITextView!
    @IBOutlet weak var bottomBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendChatBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
// MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        
        tableView.separatorColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        initContextTextView()
        initSendChatBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = true
        addAdditionalHeightToBottomBar(line: 1)
        viewModel.refreshTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.writeChatRoom()
        viewModel.sceneCoordinator.closed()
    }
    
// MARK: - UI Init Methods
    private func initSendChatBtn() {
        sendChatBtn.setBackgroundColor(.gray, for: .disabled)
    }
    
    private func initContextTextView() {
        contextTextView.setCornerRadius(value: CORNER_RADIUS_VALUE)
        contextTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contextTextView.layer.borderWidth = CGFloat(0.5)
    }
    
    private func addAdditionalHeightToBottomBar(line: Int) {
        guard let font = self.contextTextView.font else { return }
        let line: Int = {
            if line >= MAX_LINE { return MAX_LINE }
            return line
        }()
        let extraSpaceByLine = font.lineHeight * CGFloat(line - 1)
        self.bottomBarHeightConstraint.constant = BOTTOM_BAR_DEFAULT_HEIGHT + extraSpaceByLine
    }
    

    func bindViewModel() {
        viewModel.chatRoomTitleSubject
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
            
        
        contextTextView.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.sendChatBtn.isEnabled = (text != "")
                self?.contextTextView.isScrollEnabled = true
                let line = self?.contextTextView.getLine()
                self?.addAdditionalHeightToBottomBar(line: line!)
                self?.contextTextView.isScrollEnabled = (line != 1)
            }).disposed(by: rx.disposeBag)
        
        viewModel.chatContextTableDataSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.chatContextTableDataSubject
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] data in
                    guard let dataAmount = data.first?.items.count else { return }
                    guard dataAmount != 0 else {return}
                    let indexPath = IndexPath(row: dataAmount-1, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            })
            .disposed(by: rx.disposeBag)
            
        sendChatBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.sendChat(text: (self?.contextTextView.text)!)
                self?.contextTextView.text = ""
            }).disposed(by: rx.disposeBag)
    }
}

extension UITextView {
    func getLine() -> Int {
        guard let font = self.font else { return 1 }
        return Int(round(self.contentSize.height / font.lineHeight)-1)
    } 
}
