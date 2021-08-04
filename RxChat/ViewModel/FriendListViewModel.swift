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
        profileInfoSubject = BehaviorSubject<[User]>(value: [
                                                        myInfo,
                                                        User(email: "test1", id: "test1", profileImg: UIImage(named: "defaultProfileImage.png")),
                                                        User(email: "test2", id: "test2", profileImg: UIImage(named: "defaultProfileImage.png"))
        ])
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    
    
}
