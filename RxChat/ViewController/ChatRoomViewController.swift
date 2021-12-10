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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.sceneCoordinator.getCurrentVC().tabBarController?.tabBar.isHidden = false
        viewModel.sceneCoordinator.closed()
    }

    func bindViewModel() {
        viewModel.chatRoomTitleSubject
            .drive(self.navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
            
        
        return
    }

}
