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
    let BOTTOM_BAR_DEFAULT_HEIGHT: CGFloat = 80
    
    @IBOutlet weak var contextTextView: UITextView!
    @IBOutlet weak var bottomBarHeightConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = false
        viewModel.sceneCoordinator.closed()
    }
    
    private func addAdditionalHeightonBottomBar() {
        guard let font = self.contextTextView.font else { return }
        let contextLine: Int = {
            let contextLine = self.contextTextView.getLine()
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
                self.addAdditionalHeightonBottomBar()
            }).disposed(by: rx.disposeBag)
    }

}


extension UITextView {
    func getLine() -> Int {
        guard let font = self.font else { return 1 }
        return Int(round(self.contentSize.height / font.lineHeight)-1)
    }
}
