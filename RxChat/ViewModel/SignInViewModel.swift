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
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                               accessToken: authentication.accessToken)
                Auth.auth().signIn(with: credential) { authResult, error in
                    guard error == nil else {
                        print("Error: Firebase Sign-in Failed")
                        print(error?.localizedDescription)
                        return
                    }
                    
                    print("Firebase Sign-in Suceed!")
                    
                    let uid = authResult!.user.uid
                    let email = authResult!.user.email
                    
                    Owner.shared.uid = uid
                    
                    // TODO: 유저 초기 저장하고 Edit완료시 Update 시간 Realm에 저장하기.
                    if RealmUtil().ownerRealmExist() {
                        print("Owner Realm exist")
                        Owner.shared.lastFriendListUpdateTime = RealmUtil().readOwner().lastFriendListUpdateTime
                        print("Owner lastFriendListUpdateTime = \(Owner.shared.lastFriendListUpdateTime)")
                    }
                    else {
                        print("Owner Realm does not exist")
                    }
                    
                    
                    print("UID: " + uid)
                    print("Email: " + email!)
                    
                    
                    let firebaseUtil = self.firebaseUtil
                    firebaseUtil.downloadMyData(uid)
                        .subscribe(onNext: { user in
                            if user != nil {
                                Owner.shared.email = user!.email
                                Owner.shared.id = user!.id
                                Owner.shared.profileImg = user!.profileImg
                                Owner.shared.friendList = user!.friendList
                                print("User exist")
                            }
                            else {
                                Owner.shared.uid = uid
                                Owner.shared.email = email!
                                Owner.shared.id = nil
                                Owner.shared.profileImg = nil
                                Owner.shared.friendList = []
                                print("User not exist")
                            }
                            
                            let editProfileViewModel = EditProfileViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let editProfileScene = Scene.editProfile(editProfileViewModel)
                            self.sceneCoordinator.transition(to: editProfileScene, using: .fullScreen, animated: true)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
            return Observable.empty()
        }
    }()
}
