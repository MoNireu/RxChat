//
//  GroupChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import OrderedCollections


class GroupChatListViewModel: CommonViewModel {
    
    var orderedDict: OrderedDictionary<String, Int> = [:]
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
//        orderedDict.updateValue(4, forKey: "four")
//        orderedDict.updateValue(3, forKey: "three")
//        orderedDict.updateValue(2, forKey: "two")
//        orderedDict.updateValue(1, forKey: "one")
//        print("Log -", #fileID, #function, #line, orderedDict)
//        orderedDict.sort(by: {$0.value < $1.value})
//        print("Log -", #fileID, #function, #line, orderedDict)
//        orderedDict.updateValue(6, forKey: "three")
//        orderedDict.updateValue(8, forKey: "four")
//        print("Log -", #fileID, #function, #line, orderedDict)
    }
    
}
