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
//    var disposeBag = DisposeBag()
//    var chatByUserId: OrderedDictionary<String, Chat> = [:] //[userId: roomUUID]
//    var roomUUIDByUserId: [String: String] = [:] //[userId: roomUUID]
//    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
//        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
//        self.addListener()
//        self.addNewRoomListener()
//    }
//
//    private func addListener() {
//        ChatUtility.shared.getPrivateChatRoomUUIDDict()
//            .subscribe(onNext: { dict in
//                self.roomUUIDByUserId = dict
//                let chatRoomUUIDList = Array(dict.values)
//                ChatUtility.shared.listenPrivateLastMessage(UUIDList: chatRoomUUIDList)
//                    .subscribe(onNext: { lastChatDict in
//                        self.addChatDictAndSort(lastChatDict: lastChatDict)
//                    }).disposed(by: self.disposeBag)
//            }).disposed(by: self.disposeBag)
//    }
//
//    private func addNewRoomListener() {
//        ChatUtility.shared.listenOwnerChatRoom()
//            .subscribe(onNext: { newRoom in
//                let key = newRoom.first!.key
//                let val = newRoom.first!.value
//                self.roomUUIDByUserId.updateValue(val, forKey: key)
//                ChatUtility.shared.listenPrivateLastMessage(UUIDList: [val])
//                    .subscribe(onNext: { lastChatDic in
//                        self.addChatDictAndSort(lastChatDict: lastChatDic)
//                    }).disposed(by: self.disposeBag)
//            }).disposed(by: self.disposeBag)
//    }
//
//    private func addChatDictAndSort(lastChatDict: [String: Chat]?) {
//        guard let lastChatDict = lastChatDict else { return } // 마지막 채팅이 존재하지 않는경우(보통 초기 생성된 방)
//        let roomUUID = lastChatDict.first?.key
//        let userId = self.roomUUIDByUserId.first(where: {$1 == roomUUID})?.key
//        self.chatByUserId.updateValue(lastChatDict.first!.value, forKey: userId!)
//        self.chatByUserId.sort(by: {$0.value.time! > $1.value.time!})
//        print("Log -", #fileID, #function, #line, self.chatByUserId)
//    }
}
