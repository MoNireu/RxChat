//
//  Scene.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import UIKit


enum Scene {
    case launch(LaunchViewModel)
    case signIn(SignInViewModel)
    case editProfile(CreateProfileViewModel)
    case chatList(FriendListViewModel, PrivateChatListViewModel, GroupChatListViewModel)
    case findUser(FindUserViewModel)
    case chatRoom(ChatRoomViewModel)
    case chatSummary(ChatSummaryViewModel)
    case groupChatMemberSelect(CreateGroupChatViewModel)
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
          
        case .launch(let viewModel):
            guard var launchVC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.launch) as? LaunchViewController else {
                fatalError()
            }
            launchVC.bind(viewModel: viewModel)
            
            return launchVC
            
            
        case .signIn(let viewModel):
            guard var signInVC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.signIn) as? SignInViewController else {
                fatalError()
            }
            
            signInVC.bind(viewModel: viewModel)
            
            return signInVC
            
        case .editProfile(let viewModel):
            guard var createProfileVC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.createProfile) as? CreateProfileViewController else {
                fatalError()
            }
            
            createProfileVC.bind(viewModel: viewModel)
            
            return createProfileVC
            
            
        case .chatList(let viewModel1, let viewModel2, let viewModel3):
            guard let chatListTBC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.TBC.chatList) as? UITabBarController else {
                fatalError()
            }
            
            guard let friendListNav = chatListTBC.viewControllers?[0] as? UINavigationController else {
                fatalError()
            }
            guard var friendListVC = friendListNav.viewControllers.first as? FriendListViewController else {
                fatalError()
            }
            
            guard let privateChatListNav = chatListTBC.viewControllers?[1] as? UINavigationController else {
                fatalError()
            }
            guard var privateChatListVC = privateChatListNav.viewControllers.first as? PrivateChatListViewController else {
                fatalError()
            }
            
            guard let groupChatListNav = chatListTBC.viewControllers?[2] as? UINavigationController else {
                fatalError()
            }
            guard var groupChatListVC = groupChatListNav.viewControllers.first as? GroupChatListViewController else {
                fatalError()
            }
            
            friendListVC.bind(viewModel: viewModel1)
            privateChatListVC.bind(viewModel: viewModel2)
            groupChatListVC.bind(viewModel: viewModel3)
            
            chatListTBC.viewControllers?[0] = friendListNav
            chatListTBC.viewControllers?[1] = privateChatListNav
            chatListTBC.viewControllers?[2] = groupChatListNav
            
            return chatListTBC
            
        case .findUser(let viewModel):
            guard var findUserVC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.findUser) as? FindUserViewController else {
                fatalError()
            }
            findUserVC.bind(viewModel: viewModel)
            return findUserVC
            
        case .chatRoom(let viewModel):
            guard var chatRoomVC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.chatRoom) as? ChatRoomViewController else {
                fatalError()
            }
            
            chatRoomVC.bind(viewModel: viewModel)
            return chatRoomVC
            
        case .chatSummary(let viewModel):
            guard var chatSummaryVC = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.chatSummary) as? ChatSummaryViewController else {
                fatalError()
            }
            chatSummaryVC.bind(viewModel: viewModel)
            return chatSummaryVC
            
        case .groupChatMemberSelect(let viewModel):
            guard var vc = storyboard.instantiateViewController(withIdentifier: IdentifierUtil.VC.groupChatMemberSelect) as? CreateGroupChatViewController else {
                fatalError()
            }
            vc.modalPresentationStyle = .fullScreen
            vc.bind(viewModel: viewModel)
            return vc
        }
    }
}
