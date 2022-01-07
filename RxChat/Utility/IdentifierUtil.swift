//
//  Identities.swift
//  RxChat
//
//  Created by MoNireu on 2022/01/01.
//

import Foundation


enum IdentifierUtil {
    enum TBC {
        static let chatList = "ChatListTBC"
    }
    enum NAV {
        static let friendList = "FriendListNAV"
        static let privateChat = "PrivateChatNAV"
        static let groupChat = "GroupChatNAV"
    }
    enum VC {
        static let launch = "LaunchVC"
        static let signIn = "SignInVC"
        static let createProfile = "CreateProfileVC"
        static let chatRoom = "ChatRoomVC"
        static let chatSummary = "ChatSummaryVC"
        static let privateChatList = "PrivateChatListVC"
        static let groupChatList = "GroupChatListVC"
        static let friendList = "FriendListVC"
        static let findUser = "FindUserVC"
        static let groupChatMemberSelect = "GroupChatMemberSelectVC"
    }
    enum TableCell {
        static let myProfile = "MyProfileCell"
        static let friendProfile = "FriendProfileCell"
        static let friendProfileSelect = "FriendProfileSelectCell"
        static let privateChatList = "PrivateChatListCell"
        static let chatByOwner = "ChatByOwnerCell"
        static let chatByFriend = "ChatByFriendCell"
        static let chatByFriendWithProfileImage = "ChatByFriendWithProfileImage"
        static let groupChatListOneMember = "GroupChatListOneMemberCell"
        static let groupChatListTwoMember = "GroupChatListTwoMemberCell"
        static let groupChatListThreeMember = "GroupChatListThreeMemberCell"
        static let groupChatListFourMember = "GroupChatListFourMemberCell"
    }
    enum CollectionCell {
        static let groupChatMemberSelect = "GroupChatMemberSelectCell"
        static let chatSummaryGroups = "ChatSummaryGroupsCell"
    }
}
