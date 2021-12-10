//
//  ChatRoomViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/11/26.
//

import Foundation
import RxSwift
import RxCocoa

class ChatRoomViewModel: CommonViewModel {
    
    var chatRoomTitle: String
    var chatRoomTitleSubject: Driver<String>
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, chatRoom: ChatRoom) {
        
        chatRoomTitle = chatRoom.title
        chatRoomTitleSubject = Driver<String>.just(chatRoom.title)
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
}
