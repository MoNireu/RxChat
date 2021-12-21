//
//  PrivateChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import OrderedCollections

class PrivateChatListViewModel: CommonViewModel {
    var disposeBag = DisposeBag()
    let chatUtility = ChatUtility()
    var chatByUserId: OrderedDictionary<String, Chat> = [:] //[userId: roomUUID]
    var roomUUIDByUserId: [String: String] = [:] //[userId: roomUUID]
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        self.addListener()
    }
    
    func addListener() {
        chatUtility.getPrivateChatRoomUUIDDict()
            .subscribe(onNext: { dict in
                self.roomUUIDByUserId = dict
                let chatRoomUUIDList = Array(dict.values)
                self.chatUtility.addListenerToPrivateLastMessage(UUIDList: chatRoomUUIDList)
                    .subscribe(onNext: { chatDict in
                        guard let chatDict = chatDict else { return } // 마지막 채팅이 존재하지 않는경우(보통 초기 생성된 방)
                        let roomUUID = chatDict.first?.key
                        let userId = self.roomUUIDByUserId.first(where: {$1 == roomUUID})?.key
                        self.chatByUserId.updateValue(chatDict.first!.value, forKey: userId!)
                        self.chatByUserId.sort(by: {$0.value.time! > $1.value.time!})
                        print("Log -", #fileID, #function, #line, self.chatByUserId)
                    }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }
}
