//
//  PrivateChatListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import Action
import RxDataSources
import OrderedCollections
import SwiftUI

class PrivateChatListViewModel: ChatListViewModel {
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        filteredChatRoom = Array(chatRoomByRoomId.values)
        addNewRoomListener(roomType: .privateRoom)
        observeQuery()
    }
    
    let dataSource: RxTableViewSectionedReloadDataSource<SectionOfChatRoomData> = {
        return RxTableViewSectionedReloadDataSource<SectionOfChatRoomData> (configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: IdentifierUtil.TableCell.privateChatList) as? PrivateChatListTableViewCell else {
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
}
