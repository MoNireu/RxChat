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
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        signInConfig = appdelegate.signInConfig
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    lazy var signInComplete: CocoaAction = {
        return Action { _ in
            
            GIDSignIn.sharedInstance.signIn(with: self.signInConfig, presenting: self.sceneCoordinator.getCurrentVC()) { user, error in
                guard error == nil else { return }
                
                print("GoogleSign-in Suceed!")
                
                guard let authentication = user?.authentication else { return }
                self.firebaseUtil.ownerSignIn(authentication: authentication)
                    .subscribe(onCompleted: {
                        let editProfileViewModel = EditProfileViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                        let editProfileScene = Scene.editProfile(editProfileViewModel)
                        self.sceneCoordinator.transition(to: editProfileScene, using: .fullScreen, animated: true)
                    })
//                self.firebaseUtil.ownerSignIn(authentication: authentication) {
//                    let editProfileViewModel = EditProfileViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
//                    let editProfileScene = Scene.editProfile(editProfileViewModel)
//                    self.sceneCoordinator.transition(to: editProfileScene, using: .fullScreen, animated: true)
//                }
            }
            
            return Observable.empty()
        }
    }()
}
