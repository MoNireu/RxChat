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
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfChatData>!
    var isListenerPreventedOnInit = false
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        chatRoomTitleSubject = Driver<String>.just(chatRoom.title)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        setDataSource()
        initDownloadPrivateChat()
    }
    
    deinit {
        print("Log -", #fileID, #function, #line, "DeInit")
    }
    
    
    func setDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfChatData>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                // 보낸 메시지
                if (item.from == Owner.shared.id) {
                    let chatTextByOwnerCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByOwner", for: indexPath) as? ChatRoomFromOwnerTableViewCell
                    chatTextByOwnerCell?.chatBubbleLabel.text = item.text
                    chatTextByOwnerCell?.timeLabel.text = item.time != nil ? item.time!.convertTimeStampToHourMinute() : ""
                    return chatTextByOwnerCell ?? UITableViewCell()
                }
                // 받은 메시지
                else {
                    let previousCellId: String = {
                        if indexPath.row == 0 {return ""}
                        else { return (self?.combinedChats[indexPath.row - 1].from)! }
                    }()
                    let currentCellId = self?.combinedChats[indexPath.row].from
                    if previousCellId == currentCellId {
                        let chatTextByFriendCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriend", for: indexPath) as? ChatRoomFromFriendTableViewCell
                        chatTextByFriendCell?.chatBubbleLabel.text = item.text
                        chatTextByFriendCell?.timeLabel.text = item.time != nil ? item.time!.convertTimeStampToHourMinute() : ""
                        
                        return chatTextByFriendCell ?? UITableViewCell()
                    }
                    else {
                        let chatTextByFriendWithProfileImageCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriendWithProfileImage", for: indexPath) as? ChatRoomFromFriendWithProfileImageTableViewCell
                        chatTextByFriendWithProfileImageCell?.chatBubbleLabel.text = item.text
                        chatTextByFriendWithProfileImageCell?.timeLabel.text = item.time != nil ? item.time!.convertTimeStampToHourMinute() : ""
                        chatTextByFriendWithProfileImageCell?.profileImage.image = Owner.shared.friendList[item.from]?.profileImg
                        chatTextByFriendWithProfileImageCell?.idLabel.text = Owner.shared.friendList[item.from]?.name
                        
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
        
        ChatUtility.shared.getChatsBy(roomId: chatRoom.UUID, startingId: lastChatId)
            .subscribe(onNext: { [weak self] chatList in
                print("Log -", #fileID, #function, #line, chatList)
                guard chatList.count != 0 else {
                    self?.addListenerToChatRoom()
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
                self?.newChats.append(contentsOf: downloadedPrivateChat)
                self?.addListenerToChatRoom()
            }).disposed(by: self.disposeBag)
    }
    
    func addListenerToChatRoom() {
        ChatUtility.shared.listenChat(roomId: chatRoom.UUID)
            .subscribe(onNext: { [weak self] chat in
                guard (self?.isListenerPreventedOnInit)! else {
                    print("Log -", #fileID, #function, #line, "Listener Prevented On Init")
                    self?.isListenerPreventedOnInit = true
                    self?.refreshTableView()
                    return
                }
                
                guard let chat = chat else {return}
                print("Log -", #fileID, #function, #line, "New Chat: \(dump(chat))")
                self?.newChats.append(chat)
                // 전송 중인 채팅 있음
                if chat.from == Owner.shared.id && !(self?.sendingChats.isEmpty)! {
                    self?.sendingChats.removeFirst()
                }
                self?.refreshTableView()
            }).disposed(by: self.disposeBag)
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
        
        ChatUtility.shared.sendMessage(roomId: chatRoom.UUID, text: text)
            .subscribe(onNext: {  _ in})
            .disposed(by: self.disposeBag)
    }
    
    func writeChatRoom() {
        self.chatRoom.chats = newChats
        RealmUtil.shared.writeChatRoom(chatRoom: self.chatRoom)
    }
}
