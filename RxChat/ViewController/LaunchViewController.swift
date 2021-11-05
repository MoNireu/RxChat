//
//  LaunchViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/11/04.
//

import UIKit
import GoogleSignIn

class LaunchViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: LaunchViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneCoordinator = viewModel.sceneCoordinator
        let firebaseUtil = viewModel.firebaseUtil
        
        // 기존 로그인 체크
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            
            // 기존 로그인 존재시
            if error == nil && user != nil {
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("GID: SignIn Succeed!")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                
                // FriendList로 이동
                guard let authentication = user?.authentication else { return }
                self.viewModel.firebaseUtil.ownerSignIn(authentication: authentication)
                    .subscribe(onCompleted: {
                        // change to scene "FriendList"
                        let friendListVM = FriendListViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                        let privateChatListVM = PrivateChatListViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                        let groupChatListVM = GroupChatListViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                        let chatListScene = Scene.chatList(friendListVM, privateChatListVM, groupChatListVM)
                        sceneCoordinator.transition(to: chatListScene, using: .root, animated: true)
                    })
            }
            // 기존 로그인 존재하지 않을 시
            else {
                // SignIn으로 이동.
                let signInViewModel = SignInViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                let signInScene = Scene.signIn(signInViewModel)
                sceneCoordinator.transition(to: signInScene, using: .root, animated: true)
            }
        }
    }
    
    func bindViewModel() {
        // asdf
    }
}
