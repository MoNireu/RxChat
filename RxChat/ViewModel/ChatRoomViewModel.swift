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

    var chatRoom: ChatRoom
    var chatRoomTitleSubject: Driver<String>
    var chatContextItemList: [Chat]!
    var chatContextTableData: [SectionOfChatData]!
    var chatContextTableDataSubject: BehaviorSubject<[SectionOfChatData]>!
    var disposeBag = DisposeBag()
    lazy var chatUtility = ChatUtility()
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, chatRoom: ChatRoom) {
        
        self.chatRoom = chatRoom
        chatRoomTitleSubject = Driver<String>.just(chatRoom.title)
        
        chatContextItemList = []
        
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
              cell?.timeLabel.text = item.time != nil ? convertTimeToDateFormat(timestamp: (item.time)!) : ""
              return cell ?? UITableViewCell()
          }
          // 내가 받은 메시지
          else {
              let cell = tableView.dequeueReusableCell(withIdentifier: "chatTextByFriend", for: indexPath) as? ChatRoomFromFriendTableViewCell
              cell?.chatBubbleLabel.text = item.text
              cell?.timeLabel.text = item.time != nil ? convertTimeToDateFormat(timestamp: (item.time)!) : ""
              return cell ?? UITableViewCell()
          }
    })
    
    
    static func convertTimeToDateFormat(timestamp: String) -> String {
        let hourStartIdx = timestamp.index(timestamp.startIndex, offsetBy: 8)
        let hourEndIdx = timestamp.index(timestamp.startIndex, offsetBy: 9)
        let minuteStartIdx = timestamp.index(timestamp.startIndex, offsetBy: 10)
        let minuteEndIdx = timestamp.index(timestamp.startIndex, offsetBy: 11)
        let hour = timestamp[hourStartIdx...hourEndIdx]
        let minute = timestamp[minuteStartIdx...minuteEndIdx]
        return "\(hour):\(minute)"
    }
    
    
    private func refreshTableView() {
        self.chatContextTableData = [SectionOfChatData(header: "", items: self.chatContextItemList)]
        self.chatContextTableDataSubject.onNext(self.chatContextTableData)
    }
    
    
    func sendChat(text: String) {
        let tmpChat = Chat(from: Owner.shared.id!, to: nil, text: text, time: nil)
        self.chatContextItemList.append(tmpChat)
        refreshTableView()
        
        chatUtility.sendMessage(UUID: chatRoom.UUID, text: text)
            .subscribe(onNext: { [self] chat in
                self.chatContextItemList.remove(at: chatContextItemList.lastIndex(where: { oldChat in
                    return oldChat === tmpChat
                })!)
                self.chatContextItemList.append(chat)
                refreshTableView()
            }).disposed(by: self.disposeBag)
    }
    
    
    
}
