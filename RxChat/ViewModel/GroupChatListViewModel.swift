//
//  GroupChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RxDataSources
import OrderedCollections


class GroupChatListViewModel: CommonViewModel {
    var disposeBag = DisposeBag()
    var chatRoomByRoomId: OrderedDictionary<String, ChatRoom> = [:] // [roomId: ChatRoom]
    var chatRoomByRoomIdSubject = PublishSubject<OrderedDictionary<String, ChatRoom>>()
    var tableData: [SectionOfChatRoomData]!
    var tableDataSubject = BehaviorSubject<[SectionOfChatRoomData]>(value: [])
    static var todayMonthDay: String = {
        let today = DateFormatter().dateToDefaultFormat(date:Date())
        return today.convertTimeStampToMonthDay()
    }()
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        addNewRoomListener()
    }
    
    let dataSource: RxTableViewSectionedReloadDataSource<SectionOfChatRoomData> = {
        return RxTableViewSectionedReloadDataSource<SectionOfChatRoomData> (configureCell: { dataSource, tableView, indexPath, item in
            let groupChatListCell: GroupChatListTableViewCell = {
                var cell: GroupChatListTableViewCell?
                switch item.members.count {
                case 1:
                    let oneMemberCell = tableView.dequeueReusableCell(withIdentifier: IdentifierUtil.TableCell.groupChatListOneMember) as? GroupChatListOneMemberTableViewCell
                    let memberOneId = item.members[0]
                    oneMemberCell?.memberOneImageView.image = Owner.shared.getUserProfileImage(userId: memberOneId)
                    cell = oneMemberCell
                case 2:
                    let twoMemberCell = tableView.dequeueReusableCell(withIdentifier: IdentifierUtil.TableCell.groupChatListTwoMember) as? GroupChatListTwoMemberTableViewCell
                    let memberOneId = item.members[0]
                    let memberTwoId = item.members[1]
                    twoMemberCell?.memberOneImageView.image = Owner.shared.getUserProfileImage(userId: memberOneId)
                    twoMemberCell?.memberTwoImageView.image = Owner.shared.getUserProfileImage(userId: memberTwoId)
                    cell = twoMemberCell
                case 3:
                    let threeMemberCell = tableView.dequeueReusableCell(withIdentifier: IdentifierUtil.TableCell.groupChatListThreeMember) as? GroupChatListThreeMemberTableViewCell
                    let memberOneId = item.members[0]
                    let memberTwoId = item.members[1]
                    let memberThreeId = item.members[2]
                    threeMemberCell?.memberOneImageView.image = Owner.shared.getUserProfileImage(userId: memberOneId)
                    threeMemberCell?.memberTwoImageView.image = Owner.shared.getUserProfileImage(userId: memberTwoId)
                    threeMemberCell?.memberThreeImageView.image = Owner.shared.getUserProfileImage(userId: memberThreeId)
                    cell = threeMemberCell
                default:
                    let fourMemberCell = tableView.dequeueReusableCell(withIdentifier: IdentifierUtil.TableCell.groupChatListFourMember) as? GroupChatListFourMemberTableViewCell
                    let memberOneId = item.members[0]
                    let memberTwoId = item.members[1]
                    let memberThreeId = item.members[2]
                    let memberFourId = item.members[3]
                    fourMemberCell?.memberOneImageView.image = Owner.shared.getUserProfileImage(userId: memberOneId)
                    fourMemberCell?.memberTwoImageView.image = Owner.shared.getUserProfileImage(userId: memberTwoId)
                    fourMemberCell?.memberThreeImageView.image = Owner.shared.getUserProfileImage(userId: memberThreeId)
                    fourMemberCell?.memberFourImageView.image = Owner.shared.getUserProfileImage(userId: memberFourId)
                    cell = fourMemberCell
                }
                guard let cell = cell else { return GroupChatListTableViewCell() }
                return cell
            }()
            
            let lastChat = item.chats.first!
            groupChatListCell.roomTitleLbl.text = item.title
            groupChatListCell.roomLastChatLbl.text = lastChat.text
            
            
            if todayMonthDay == lastChat.time?.convertTimeStampToMonthDay() {
                groupChatListCell.roomLastChatTimeLbl.text = lastChat.time?.convertTimeStampToHourMinute()
            }
            else {
                groupChatListCell.roomLastChatTimeLbl.text = lastChat.time?.convertTimeStampToMonthDay()
            }
            return groupChatListCell
        })
    }()

    private func addNewRoomListener() {
        ChatUtility.shared.listenNewRoom(roomType: .groupRoom)
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
