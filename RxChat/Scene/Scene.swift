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
            
            guard var friendListVC = chatListTBC.viewControllers?[0] as? FriendListViewController else {
                fatalError()
            }
            
            guard var privateChatListVC = chatListTBC.viewControllers?[1] as? PrivateChatListViewController else {
                fatalError()
            }
            
            guard var groupChatListVC = chatListTBC.viewControllers?[2] as? GroupChatListViewController else {
                fatalError()
            }
            
            friendListVC.bind(viewModel: viewModel1)
            privateChatListVC.bind(viewModel: viewModel2)
            groupChatListVC.bind(viewModel: viewModel3)
            
            chatListTBC.viewControllers?[0] = friendListVC
            chatListTBC.viewControllers?[1] = privateChatListVC
            chatListTBC.viewControllers?[2] = groupChatListVC
            
            return chatListTBC
        }
    }
}
