//
//  ChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2022/01/10.
//

import Foundation
import RxSwift
import Action
import RxDataSources
import OrderedCollections
import SwiftUI

class ChatListViewModel: CommonViewModel {
    var disposeBag = DisposeBag()
    var chatRoomByRoomId: OrderedDictionary<String, ChatRoom> = [:] // [roomId: ChatRoom]
    var filteredChatRoom: [ChatRoom]
    var tableData: [SectionOfChatRoomData]!
    var tableDataSubject = BehaviorSubject<[SectionOfChatRoomData]>(value: [])
    var query: String = ""
    var querySubject = BehaviorSubject<String>(value: "")
    static var todayMonthDay: String = {
        let today = DateFormatter().dateToDefaultFormat(date:Date())
        return today.convertTimeStampToMonthDay()
    }()
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        filteredChatRoom = Array(chatRoomByRoomId.values)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        observeQuery()
    }
    
    func addNewRoomListener(roomType: ChatRoomType) {
        ChatUtility.shared.listenNewRoom(roomType: roomType)
            .subscribe(onNext: { newRoom in
                let roomId = newRoom.first!.value
                print("Log -", #fileID, #function, #line, roomId)
                
                // 채팅방에 리스너 추가
                ChatUtility.shared.listenChat(roomId: roomId)
                    .subscribe(onNext: { chat in
                        guard let chat = chat else {return}
                        
                        // 방 정보와 채팅을 조합.
                        guard self.chatRoomByRoomId[roomId] != nil
                        else {
                            ChatUtility.shared.getChatRoomFromFirebaseBy(roomId: roomId)
                                .subscribe(onNext: { chatRoom in
                                    chatRoom.chats = [chat]
                                    self.chatRoomByRoomId.updateValue(chatRoom, forKey: roomId, insertingAt: 0)
                                    self.chatRoomByRoomId.sort(by: {$0.value.chats.first!.time! > $1.value.chats.first!.time!})
                                    self.refreshTable()
                                }).disposed(by: self.disposeBag)
                            return
                        }
                        let chatRoom = self.chatRoomByRoomId[roomId]!
                        chatRoom.chats = [chat]
                        self.chatRoomByRoomId.removeValue(forKey: roomId)
                        self.chatRoomByRoomId.updateValue(chatRoom, forKey: roomId, insertingAt: 0)
                        self.refreshTable()
                        print("Log -", #fileID, #function, #line, "\(roomId):\(chat)")
                    }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }
    
    
    func refreshTable() {
        let today = DateFormatter().dateToDefaultFormat(date:Date())
        PrivateChatListViewModel.todayMonthDay = today.convertTimeStampToMonthDay()
        
        filterChatRoomBy(query: self.query)
        tableData = [SectionOfChatRoomData(header: "", items: filteredChatRoom)]
        tableDataSubject.onNext(tableData)
    }
    
    
    lazy var presentChatRoom: Action<ChatRoom, Void> = {
        return Action { [weak self] chatRoom in
            let friendId = chatRoom.getFriendIdFromChatRoom()
            ChatUtility.shared.preparePrivateChatRoomForTransition(friendId: friendId)
                .subscribe(onNext: { [weak self] chatRoom in // 채팅방으로 이동.
                    let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: (self?.sceneCoordinator)!, firebaseUtil: (self?.firebaseUtil)!, chatRoom: chatRoom)
                    let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                    self?.sceneCoordinator.transition(to: chatRoomScene, using: .dismissThenPushOnPrivateTab, animated: true)
                    print("Connecting to room number: \(chatRoom.UUID)")
                }).disposed(by: (self?.disposeBag)!)
            return Observable.empty()
        }
    }()
    
    
    func observeQuery() {
        querySubject.subscribe(onNext: { [weak self] query in
            self?.query = query
            self?.refreshTable()
        }).disposed(by: self.disposeBag)
    }
    
    private func filterChatRoomBy(query: String) {
        let chatRoomValues = Array(self.chatRoomByRoomId.values)
        
        if query.isEmpty { self.filteredChatRoom = chatRoomValues }
        else {
            self.filteredChatRoom = chatRoomValues.filter({ chatRoom in
                if chatRoom.title.contains(query) { return true }
                for memberId in chatRoom.members {
                    if memberId == Owner.shared.id! { continue }
                    if Owner.shared.friendList[memberId]!.name!.contains(query) { return true }
                }
                return false
            })
        }
    }
}
