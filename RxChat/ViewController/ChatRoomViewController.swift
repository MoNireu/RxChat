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

class ChatRoomViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: ChatRoomViewModel!
    
    let MAX_LINE: Int = 5
    let BOTTOM_BAR_DEFAULT_HEIGHT: CGFloat = 84
    let CORNER_RADIUS_VALUE: Float = 0.02

    
    @IBOutlet weak var contextTextView: UITextView!
    @IBOutlet weak var bottomBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendChatBtn: UIButton!
    
// MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        initContextTextView()
        initSendChatBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addAdditionalHeightonBottomBar(contextLine: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = false
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
    
    private func addAdditionalHeightonBottomBar(contextLine: Int) {
        guard let font = self.contextTextView.font else { return }
        let contextLine: Int = {
            if contextLine >= MAX_LINE { return MAX_LINE }
            return contextLine
        }()
        let extraSpaceByLine = font.lineHeight * CGFloat(contextLine - 1)
        self.bottomBarHeightConstraint.constant = BOTTOM_BAR_DEFAULT_HEIGHT + extraSpaceByLine
    }

    func bindViewModel() {
        viewModel.chatRoomTitleSubject
            .drive(self.navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
            
        
        contextTextView.rx.text
            .subscribe(onNext: { text in
                self.sendChatBtn.isEnabled = (text != "")
                
                self.contextTextView.isScrollEnabled = true
                let line = self.contextTextView.getLine()
                self.addAdditionalHeightonBottomBar(contextLine: line)
                self.contextTextView.isScrollEnabled = (line != 1)
            }).disposed(by: rx.disposeBag)
        
    }

}


extension UITextView {
    func getLine() -> Int {
        guard let font = self.font else { return 1 }
        return Int(round(self.contentSize.height / font.lineHeight)-1)
    }
        
    func setCornerRadius(value: Float) {
        self.layer.cornerRadius = self.frame.size.width * CGFloat(value)
        self.clipsToBounds = true
    }
}
