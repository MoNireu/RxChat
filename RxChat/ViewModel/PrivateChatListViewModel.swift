//
//  PrivateChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import RxDataSources

class PrivateChatListViewModel: CommonViewModel {
    var disposeBag = DisposeBag()
    var chatRoomByRoomId: [String: ChatRoom] = [:] // [roomId: ChatRoom]
    var chatByRoomId: [String: Chat] = [:] // [roomId: Chat]
    var chatByRoomIdSubject = PublishSubject<[String: Chat]>()
    var tableData: [SectionOfChatRoomData]!
    var tableDataSubject = BehaviorSubject<[SectionOfChatRoomData]>(value: [])

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
            cell.roomTitleLbl.text = item.title
            cell.roomLastChatLbl.text = lastChat.text
            cell.roomLastChatTimeLbl.text = lastChat.time?.convertTimeToDateFormat()
            return cell
        })
    }()

    private func addNewRoomListener() {
        ChatUtility.shared.listenRoomIdByFriendId(roomType: .privateRoom)
            .subscribe(onNext: { newRoom in
                let roomId = newRoom.first!.value
                print("Log -", #fileID, #function, #line, roomId)
                
                // 채팅방에 리스너 추가
                ChatUtility.shared.listenChat(roomId: roomId)
                    .subscribe(onNext: { chat in
                        guard let chat = chat else {return}
                        self.chatByRoomId.updateValue(chat, forKey: roomId)
                        
                        
                        guard self.chatRoomByRoomId[roomId] != nil else { // 방 정보가 없을경우
                            // 방 정보 가져오기
                            ChatUtility.shared.getChatRoomBy(roomId: roomId)
                                .subscribe(onNext: { chatRoom in
                                    self.chatRoomByRoomId.updateValue(chatRoom, forKey: roomId)
                                    self.chatByRoomIdSubject.onNext(self.chatByRoomId)
                                }).disposed(by: self.disposeBag)
                            return
                        }
                        self.chatByRoomIdSubject.onNext(self.chatByRoomId)
                        print("Log -", #fileID, #function, #line, "\(roomId):\(chat)")
                    }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }
    

    func refreshTable() {
        var lastChatList: [ChatRoom] = []
        for (roomId, chat) in chatByRoomId {
            print("Log -", #fileID, #function, #line, "\(roomId): \(chat)")
            let chatRoom = chatRoomByRoomId[roomId]!
            chatRoom.chats = [chat]
            lastChatList.append(chatRoom)
        }
        lastChatList.sort(by: {$0.chats.first!.time! > $1.chats.first!.time!})
        tableData = [SectionOfChatRoomData(header: "", items: lastChatList)]
        tableDataSubject.onNext(tableData)
        print("Log -", #fileID, #function, #line, lastChatList)
    }
}
