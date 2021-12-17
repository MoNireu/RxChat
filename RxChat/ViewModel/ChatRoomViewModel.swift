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
    var chatContextItemList: [Chat] = []
    var chatContextTableData: [SectionOfChatData]!
    var chatContextTableDataSubject = PublishSubject<[SectionOfChatData]>()
    var disposeBag = DisposeBag()
    var chatUtility = ChatUtility()
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        chatRoomTitleSubject = Driver<String>.just(chatRoom.title)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        addListenerToChatRoom()
    }
    
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfChatData>(
      configureCell: { dataSource, tableView, indexPath, item in
          // 내가 보낸 메시지
          if (item.from == Owner.shared.id) {
              let chatTextByOwnerCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByOwner", for: indexPath) as? ChatRoomFromOwnerTableViewCell
              chatTextByOwnerCell?.chatBubbleLabel.text = item.text
              chatTextByOwnerCell?.timeLabel.text = item.time != nil ? convertTimeToDateFormat(timestamp: (item.time)!) : ""
              return chatTextByOwnerCell ?? UITableViewCell()
          }
          // 내가 받은 메시지
          else {
              let chatTextByFriendCell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriend", for: indexPath) as? ChatRoomFromFriendTableViewCell
              chatTextByFriendCell?.chatBubbleLabel.text = item.text
              chatTextByFriendCell?.timeLabel.text = item.time != nil ? convertTimeToDateFormat(timestamp: (item.time)!) : ""
//              chatTextByFriendCell?.profileImage.image = Owner.shared.friendList[item.from]?.profileImg
              return chatTextByFriendCell ?? UITableViewCell()
          }
    })
    
    func addListenerToChatRoom() {
        chatUtility.addListenerToPrivateChatRoom(UUID: chatRoom.UUID)
            .subscribe(onNext: { chatList in
                print("Log -", #fileID, #function, #line, "")
                self.chatContextItemList = chatList
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
        self.chatContextTableData = [SectionOfChatData(header: "", items: self.chatContextItemList)]
        self.chatContextTableDataSubject.onNext(self.chatContextTableData)
    }
    
    
    func sendChat(text: String) {
        let tmpChat = Chat(from: Owner.shared.id!, to: nil, text: text, time: nil)
        self.chatContextItemList.append(tmpChat)
        refreshTableView()
        
        chatUtility.sendMessage(UUID: chatRoom.UUID, text: text)
            .subscribe(onNext: { _ in })
            .disposed(by: self.disposeBag)
    }
}
