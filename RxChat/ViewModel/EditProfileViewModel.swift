//
//  EditProfileViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/13.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import Firebase
import RxFirebase

class EditProfileViewModel: CommonViewModel {
    let disposeBag = DisposeBag()
    
    var ownerInfo: User
    var ownerInfoSubject: BehaviorSubject<User>
    
    init(ownerInfo: User, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.ownerInfo = ownerInfo
        ownerInfoSubject = BehaviorSubject<User>(value: ownerInfo)
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    lazy var profileEditDone: Action<UIImage?, Void> = {
        return Action { image in
            self.ownerInfoSubject
                .subscribe(onNext: { user in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Profile Edit Done!")
                    print("email: \(user.email)")
                    print("id: \(user.id)")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    self.firebaseUtil.uploadProfileImage(user.email, image!)
                })
            return Observable.empty()
        }
        
    }()
}
