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
        }
    }
}
