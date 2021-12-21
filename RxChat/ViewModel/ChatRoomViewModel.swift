//
//  ChatRoomViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/11/26.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Action
import FirebaseDatabase

class ChatRoomViewModel: CommonViewModel {
    
    var chatRoom: ChatRoom
    var chatRoomTitleSubject: Driver<String>
    var newChats: [Chat] = []
    var sendingChats: [Chat] = []
    var combinedChats: [Chat] = []
    var chatContextTableData: [SectionOfChatData]!
    var chatContextTableDataSubject = PublishSubject<[SectionOfChatData]>()
    var disposeBag = DisposeBag()
    var chatUtility = ChatUtility()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfChatData>!
    var isListenerPreventedOnInit = false
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        chatRoomTitleSubject = Driver<String>.just(chatRoom.title)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        setDataSource()
        initDownloadPrivateChat()
    }
    
    
    func setDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfChatData>(
            configureCell: { dataSource, tableView, indexPath, item in
                // 내가 보낸 메시지
                if (item.from == Owner.shared.id) {
                    let chatTextByOwnerCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByOwner", for: indexPath) as? ChatRoomFromOwnerTableViewCell
                    chatTextByOwnerCell?.chatBubbleLabel.text = item.text
                    chatTextByOwnerCell?.timeLabel.text = item.time != nil ? item.time!.convertTimeToDateFormat() : ""
                    return chatTextByOwnerCell ?? UITableViewCell()
                }
                // 내가 받은 메시지
                else {
                    let previousCellId: String = {
                        if indexPath.row == 0 {return ""}
                        else { return self.combinedChats[indexPath.row - 1].from }
                    }()
                    let currentCellId = self.combinedChats[indexPath.row].from
                    if previousCellId == currentCellId {
                        let chatTextByFriendCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriend", for: indexPath) as? ChatRoomFromFriendTableViewCell
                        chatTextByFriendCell?.chatBubbleLabel.text = item.text
                        chatTextByFriendCell?.timeLabel.text = item.time != nil ? item.time!.convertTimeToDateFormat() : ""
                        
                        return chatTextByFriendCell ?? UITableViewCell()
                    }
                    else {
                        let chatTextByFriendWithProfileImageCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriendWithProfileImage", for: indexPath) as? ChatRoomFromFriendWithProfileImageTableViewCell
                        chatTextByFriendWithProfileImageCell?.chatBubbleLabel.text = item.text
                        chatTextByFriendWithProfileImageCell?.timeLabel.text = item.time != nil ? item.time!.convertTimeToDateFormat() : ""
                        chatTextByFriendWithProfileImageCell?.profileImage.image = Owner.shared.friendList[item.from]?.profileImg
                        chatTextByFriendWithProfileImageCell?.idLabel.text = item.from
                        
                        return chatTextByFriendWithProfileImageCell ?? UITableViewCell()
                    }
                }
            })
    }
    
    func initDownloadPrivateChat() {
        let lastChatId: String? = {
            if chatRoom.chats.count == 0 {return nil}
            let lastChat = chatRoom.chats.last!
            return lastChat.time! + lastChat.from
        }()
        
        chatUtility.getPrivateChatFrom(UUID: chatRoom.UUID, fromId: lastChatId)
            .subscribe(onNext: { chatList in
                print("Log -", #fileID, #function, #line, chatList)
                guard chatList.count != 0 else {
                    self.addListenerToChatRoom()
                    return
                }
                let downloadedPrivateChat: [Chat] = {
                    print("Log -", #fileID, #function, #line, lastChatId)
                    if lastChatId == nil { return chatList}
                    else {
                        var chatListFirstRemoved = chatList
                        chatListFirstRemoved.remove(at: 0)
                        return chatListFirstRemoved
                    }
                }()
                self.newChats.append(contentsOf: downloadedPrivateChat)
                self.addListenerToChatRoom()
            })
            .disposed(by: self.disposeBag)
    }
    
    func addListenerToChatRoom() {
        chatUtility.addListenerToPrivateChatRoom(UUID: chatRoom.UUID)
            .subscribe(onNext: { chat in
                guard self.isListenerPreventedOnInit else {
                    self.isListenerPreventedOnInit = true
                    self.refreshTableView()
                    return
                }
                
                guard let chat = chat else {return}
                self.newChats.append(chat)
                // 전송 중인 채팅 있음
                if chat.from == Owner.shared.id {
                    self.sendingChats.removeFirst()
                }
                self.refreshTableView()
            }).disposed(by: self.disposeBag)
    }
    
    func removeListenerFromChatRoom() {
        chatUtility.removeListenerFromPrivateChatRoom(UUID: chatRoom.UUID)
    }
    
    
    
    static func convertTimeToDateFormat(timestamp: String) -> String {
        let hourStartIdx = timestamp.index(timestamp.startIndex, offsetBy: 8)
        let hourEndIdx = timestamp.index(timestamp.startIndex, offsetBy: 9)
        let minuteStartIdx = timestamp.index(timestamp.startIndex, offsetBy: 10)
        let minuteEndIdx = timestamp.index(timestamp.startIndex, offsetBy: 11)
        let hour = timestamp[hourStartIdx...hourEndIdx]
        let minute = timestamp[minuteStartIdx...minuteEndIdx]
        return "\(hour):\(minute)"
    }
    
    
    func refreshTableView() {
        combinedChats = self.chatRoom.chats + self.newChats + self.sendingChats
        self.chatContextTableData = [SectionOfChatData(header: "", items: combinedChats)]
        self.chatContextTableDataSubject.onNext(self.chatContextTableData)
    }
    
    
    func sendChat(text: String) {
        let tmpChat = Chat(from: Owner.shared.id!,text: text, time: nil)
        self.sendingChats.append(tmpChat)
        refreshTableView()
        
        chatUtility.sendMessage(UUID: chatRoom.UUID, text: text)
            .subscribe(onNext: { _ in})
            .disposed(by: self.disposeBag)
    }
    
    func writeChatRoom() {
        self.chatRoom.chats = newChats
        RealmUtil.shared.writeChatRoom(chatRoom: self.chatRoom)
    }
}


extension String {
    func convertTimeToDateFormat() -> String {
        let hourStartIdx = self.index(self.startIndex, offsetBy: 8)
        let hourEndIdx = self.index(self.startIndex, offsetBy: 9)
        let minuteStartIdx = self.index(self.startIndex, offsetBy: 10)
        let minuteEndIdx = self.index(self.startIndex, offsetBy: 11)
        let hour = self[hourStartIdx...hourEndIdx]
        let minute = self[minuteStartIdx...minuteEndIdx]
        return "\(hour):\(minute)"
    }
}
