//
//  FriendListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import UIKit


class FriendListViewModel: CommonViewModel {
    
    let myInfo: Owner
    var profileInfoSubject: BehaviorSubject<[User]>
    
    init(myInfo: Owner, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.myInfo = myInfo
        var profileInfoList = myInfo.friendList
        profileInfoList.insert(myInfo, at: 0)
        profileInfoSubject = BehaviorSubject<[User]>(value: profileInfoList)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    
    
}
