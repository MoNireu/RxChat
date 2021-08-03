//
//  FriendListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift


class FriendListViewModel: CommonViewModel {
    
    let myInfo: User
    var myInfoSubject: BehaviorSubject<[User]>
    
    init(myInfo: User, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.myInfo = myInfo
        myInfoSubject = BehaviorSubject<[User]>(value: [myInfo])
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    
    
}
