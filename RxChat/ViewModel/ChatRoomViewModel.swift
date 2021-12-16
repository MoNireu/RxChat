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

class ChatRoomViewModel: CommonViewModel {
    
    var chatRoomTitle: String
    var chatRoomTitleSubject: Driver<String>
    var chatContextItemList: [Chat]!
    var chatContextTableData: [SectionOfChatData]!
    var chatContextTableDataSubject: BehaviorSubject<[SectionOfChatData]>!
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, chatRoom: ChatRoom) {
        
        chatRoomTitle = chatRoom.title
        chatRoomTitleSubject = Driver<String>.just(chatRoom.title)
        
        chatContextItemList = [
            Chat(from: "monireu_dev", to: "coreahr_gachon", text: "가가가", time: Date(timeIntervalSinceNow: -1)),
            Chat(from: "coreahr_gachon", to: "monireu_dev", text: "나나나", time: Date(timeIntervalSinceNow: -2)),
            Chat(from: "monireu_dev", to: "coreahr_gachon", text: "다다다", time: Date(timeIntervalSinceNow: -3)),
            Chat(from: "coreahr_gachon", to: "monireu_dev", text: "라라라", time: Date(timeIntervalSinceNow: -4)),
        ]
        
        chatContextTableData = [SectionOfChatData(header: "", items: chatContextItemList)]
        chatContextTableDataSubject = BehaviorSubject(value: chatContextTableData)
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfChatData>(
      configureCell: { dataSource, tableView, indexPath, item in
          // 내가 보낸 메시지
          if (item.from == Owner.shared.id) {
              let cell = tableView.dequeueReusableCell(withIdentifier: "chatTextByOwner", for: indexPath) as? ChatRoomFromOwnerTableViewCell
              cell?.chatBubbleLabel.text = item.text
              return cell ?? UITableViewCell()
          }
          // 내가 받은 메시지
          else {
              let cell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriend", for: indexPath) as? ChatRoomFromFriendTableViewCell
              cell?.chatBubbleLabel.text = item.text
              return cell ?? UITableViewCell()
          }
    })
    
    
    func snedChat(text: String) {
        let chat = Chat(from: Owner.shared.id!, to: nil, text: text, time: Date(timeIntervalSinceNow: 0))
        self.chatContextItemList.append(chat)
        self.chatContextTableData = [SectionOfChatData(header: "", items: self.chatContextItemList)]
        self.chatContextTableDataSubject.onNext(self.chatContextTableData)
    }
    
    
    
    
    
    
}
