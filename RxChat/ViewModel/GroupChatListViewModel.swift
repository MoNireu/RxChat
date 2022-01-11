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


class GroupChatListViewModel: ChatListViewModel {
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        filteredChatRoom = Array(chatRoomByRoomId.values)
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
}
