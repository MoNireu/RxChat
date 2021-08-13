//
//  Scene.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import UIKit


enum Scene {
    case signIn(SignInViewModel)
    case editProfile(EditProfileViewModel)
    case chatList(FriendListViewModel, PrivateChatListViewModel, GroupChatListViewModel)
    case findUser(FindUserViewModel)
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .signIn(let viewModel):
            guard var signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC") as? SignInViewController else {
                fatalError()
            }
            
            signInVC.bind(viewModel: viewModel)
            
            return signInVC
            
        case .editProfile(let viewModel):
            guard var editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileViewController else {
                fatalError()
            }
            
            editProfileVC.bind(viewModel: viewModel)
            
            return editProfileVC
            
            
        case .chatList(let viewModel1, let viewModel2, let viewModel3):
            guard let chatListTBC = storyboard.instantiateViewController(withIdentifier: "ChatListTBC") as? UITabBarController else {
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
            guard var findUserVC = storyboard.instantiateViewController(withIdentifier: "FindUserVC") as? FindUserViewController else {
                fatalError()
            }
            findUserVC.bind(viewModel: viewModel)
            return findUserVC
        }
        
    }
}
