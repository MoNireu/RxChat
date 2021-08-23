//
//  FriendListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import UIKit


class FriendListViewModel: CommonViewModel {
    
    let myInfo: Owner
    var profileInfoList: [User]
    var profileInfoSubject: BehaviorSubject<[User]>
    
    init(myInfo: Owner, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.myInfo = myInfo
        profileInfoList = myInfo.friendList
        profileInfoList.insert(myInfo, at: 0)
        profileInfoSubject = BehaviorSubject<[User]>(value: profileInfoList)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    lazy var presentFindUserView: CocoaAction = {
        return Action { _ in
            let findUserViewModel = FindUserViewModel(friendListDelegate: self, sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
            let findUserScene = Scene.findUser(findUserViewModel)
            self.sceneCoordinator.transition(to: findUserScene, using: .modal, animated: true)
            return Observable.empty()
        }
    }()
    
    func refresh() {
        profileInfoSubject.onNext(profileInfoList)
    }
    
    
}
