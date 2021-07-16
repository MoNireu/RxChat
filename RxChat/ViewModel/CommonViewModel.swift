//
//  CommonViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation
import RxSwift
import RxCocoa

class CommonViewModel: NSObject {
    let sceneCoordinator: SceneCoordinatorType
    let firebaseUtil: FirebaseUtil
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.sceneCoordinator = sceneCoordinator
        self.firebaseUtil = firebaseUtil
    }
}
