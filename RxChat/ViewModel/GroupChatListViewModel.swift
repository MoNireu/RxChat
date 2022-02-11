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
    static var chatRoomById: OrderedDictionary<String, ChatRoom> = [:] // [roomId: ChatRoom]
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
        filteredChatRoom = Array(GroupChatListViewModel.chatRoomById.values)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        addNewRoomListener(roomType: .groupRoom)
        observeQuery()
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
    
    
    lazy var createGroupChatView: CocoaAction = {
        return Action { [weak self] _ in
            let CreateGroupChatViewModel = CreateGroupChatViewModel(sceneCoordinator: self!.sceneCoordinator, firebaseUtil: self!.firebaseUtil)
            let CreateGroupChatScene = Scene.groupChatMemberSelect(CreateGroupChatViewModel)
            self?.sceneCoordinator.transition(to: CreateGroupChatScene, using: .modal, animated: true)
            return Observable.empty()
        }
    }()
    
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
                        guard GroupChatListViewModel.chatRoomById[roomId] != nil
                        else {
                            ChatUtility.shared.getChatRoomFromFirebaseBy(roomId: roomId)
                                .subscribe(onNext: { chatRoom in
                                    chatRoom.chats = [chat]
                                    GroupChatListViewModel.chatRoomById.updateValue(chatRoom, forKey: roomId, insertingAt: 0)
                                    GroupChatListViewModel.chatRoomById.sort(by: {$0.value.chats.first!.time! > $1.value.chats.first!.time!})
                                    self.refreshTable()
                                }).disposed(by: self.disposeBag)
                            return
                        }
                        let chatRoom = GroupChatListViewModel.chatRoomById[roomId]!
                        chatRoom.chats = [chat]
                        GroupChatListViewModel.chatRoomById.removeValue(forKey: roomId)
                        GroupChatListViewModel.chatRoomById.updateValue(chatRoom, forKey: roomId, insertingAt: 0)
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
            ChatUtility.shared.prepareGroupChatRoomForTransition(roomId: chatRoom.UUID)
                .subscribe(onNext: { [weak self] chatRoom in // 채팅방으로 이동.
                    let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: (self?.sceneCoordinator)!, firebaseUtil: (self?.firebaseUtil)!, chatRoom: chatRoom)
                    let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                    self?.sceneCoordinator.transition(to: chatRoomScene, using: .dismissThenPushOnGroupTab, animated: true)
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
        let chatRoomValues = Array(GroupChatListViewModel.chatRoomById.values)
        
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
