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
    var chatByRoomId: OrderedDictionary<String, Chat> = [:] // [roomId: roomUUID]
    var userIdByRoomId: [String: String] = [:] // [roomUUID: userId]
    var userIdByRoomIdSubject = BehaviorSubject<[String: String]>(value: [:])
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        addNewRoomListener()
        print("Log -", #fileID, #function, #line, userIdByRoomId)
    }

    private func addNewRoomListener() {
        ChatUtility.shared.listenRoomIdByFriendId(roomType: .privateRoom)
            .subscribe(onNext: { newRoom in
                let friendId = newRoom.first!.key
                let roomId = newRoom.first!.value
                self.userIdByRoomId.updateValue(friendId, forKey: roomId)
                self.userIdByRoomIdSubject.onNext(self.userIdByRoomId)
                print("Log -", #fileID, #function, #line, "NewRoom: \(friendId)")
            }).disposed(by: self.disposeBag)
    }
    
    func updateLastMessage() {
        let roomIdList = Array(self.userIdByRoomId.keys)
        var listCount = 0
        Observable.from(roomIdList)
            .subscribe(onNext: { roomId in
                ChatUtility.shared.getLastChatFrom(roomId: roomId)
                    .subscribe(onNext: { chat in
                        guard let chat = chat else { return }
                        self.chatByRoomId.updateValue(chat, forKey: roomId)
                        listCount += 1
                        if listCount == roomIdList.count {
                            self.refreshTable()
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }

    private func refreshTable() {
        var lastChatList = Array(chatByRoomId.values)
        lastChatList.sort(by: {$0.time! > $1.time!})
        print("Log -", #fileID, #function, #line, lastChatList)
    }
}
