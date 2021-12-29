//
//  PrivateChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import RxDataSources
import OrderedCollections

class PrivateChatListViewModel: CommonViewModel {
    var disposeBag = DisposeBag()
    var chatRoomByRoomId: OrderedDictionary<String, ChatRoom> = [:] // [roomId: ChatRoom]
    var chatRoomByRoomIdSubject = PublishSubject<OrderedDictionary<String, ChatRoom>>()
    var tableData: [SectionOfChatRoomData]!
    var tableDataSubject = BehaviorSubject<[SectionOfChatRoomData]>(value: [])
    static var todayMonthDay: String = {
        let today = DateFormatter().dateToDefaultFormat(date:Date())
        return today.convertTimeStampToMonthDay()
    }()
    //    var today: String!
//    static var todayMonthDay: String!

    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        addNewRoomListener()
    }
    
    let dataSource: RxTableViewSectionedReloadDataSource<SectionOfChatRoomData> = {
        return RxTableViewSectionedReloadDataSource<SectionOfChatRoomData> (configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "privateChatListCell") as? PrivateChatListTableViewCell else {
                print("fuck")
                return UITableViewCell()
            }
            let lastChat = item.chats.first!
            let friendId: String = {
                if item.members.first! == Owner.shared.id {
                    return item.members.last!
                }
                else {
                    return item.members.first!
                }
            }()
            cell.roomImageView.image = Owner.shared.friendList[friendId]?.profileImg
            cell.roomTitleLbl.text = Owner.shared.friendList[friendId]?.name
            cell.roomLastChatLbl.text = lastChat.text
            
            
            if todayMonthDay == lastChat.time?.convertTimeStampToMonthDay() {
                cell.roomLastChatTimeLbl.text = lastChat.time?.convertTimeStampToHourMinute()
            }
            else {
                cell.roomLastChatTimeLbl.text = lastChat.time?.convertTimeStampToMonthDay()
            }
            return cell
        })
    }()

    private func addNewRoomListener() {
        ChatUtility.shared.listenNewRoom(roomType: .privateRoom)
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
                            ChatUtility.shared.getChatRoomBy(roomId: roomId)
                                .subscribe(onNext: { chatRoom in
                                    chatRoom.chats = [chat]
                                    self.chatRoomByRoomId.updateValue(chatRoom, forKey: roomId, insertingAt: 0)
                                    self.chatRoomByRoomId.sort(by: {$0.value.chats.first!.time! > $1.value.chats.first!.time!})
                                    self.chatRoomByRoomIdSubject.onNext(self.chatRoomByRoomId)
                                }).disposed(by: self.disposeBag)
                            return
                        }
                        let chatRoom = self.chatRoomByRoomId[roomId]!
                        chatRoom.chats = [chat]
                        self.chatRoomByRoomId.removeValue(forKey: roomId)
                        self.chatRoomByRoomId.updateValue(chatRoom, forKey: roomId, insertingAt: 0)
                        self.chatRoomByRoomIdSubject.onNext(self.chatRoomByRoomId)
                        print("Log -", #fileID, #function, #line, "\(roomId):\(chat)")
                    }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }
    

    func refreshTable() {
        let today = DateFormatter().dateToDefaultFormat(date:Date())
        PrivateChatListViewModel.todayMonthDay = today.convertTimeStampToMonthDay()
        
        tableData = [SectionOfChatRoomData(header: "", items: Array(chatRoomByRoomId.values))]
        tableDataSubject.onNext(tableData)
        print("Log -", #fileID, #function, #line, Array(chatRoomByRoomId.values))
    }
}
