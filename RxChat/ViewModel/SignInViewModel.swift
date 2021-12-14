//
//  SignInViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation
import Firebase
import GoogleSignIn
import RxSwift
import Action
import RealmSwift

class SignInViewModel: CommonViewModel {
    
    let disposeBag = DisposeBag()
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let signInConfig: GIDConfiguration
    var actIndicatorSubject =  BehaviorSubject<Bool>(value: false)
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        signInConfig = appdelegate.signInConfig
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    lazy var signInComplete: CocoaAction = {
        return Action { _ in
            
            self.actIndicatorSubject.onNext(true)
            GIDSignIn.sharedInstance.signIn(with: self.signInConfig, presenting: self.sceneCoordinator.getCurrentVC()) { user, error in
                guard error == nil else {
                    self.actIndicatorSubject.onNext(false)
                    return
                }
                
                print("GoogleSign-in Suceed!")
                
                guard let authentication = user?.authentication else { return }
                self.firebaseUtil.ownerSignIn(authentication: authentication)
                    .subscribe(onNext: { isNewUser in
                        if isNewUser {
                            // 이미 가입된 유저가 아닐 경우
                            // Create Profile로 이동
                            self.actIndicatorSubject.onCompleted()
                            let createProfileViewModel = CreateProfileViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let createProfileScene = Scene.editProfile(createProfileViewModel)
                            self.sceneCoordinator.transition(to: createProfileScene, using: .fullScreen, animated: true)
                        }
                        else {
                            // 이미 가입된 유저일 경우
                            // FriendList로 이동
                            let friendListVM = FriendListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let privateChatListVM = PrivateChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let groupChatListVM = GroupChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let chatListScene = Scene.chatList(friendListVM, privateChatListVM, groupChatListVM)
                            self.sceneCoordinator.transition(to: chatListScene, using: .root, animated: true)
                        }
                    }).disposed(by: self.disposeBag)
            }
            
            return Observable.empty()
        }
    }()
}
