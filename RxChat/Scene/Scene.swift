//
//  Scene.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import UIKit


enum Scene {
    case editProfile(EditProfileViewModel)
}

extension Scene {
    func instantiate(from storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .editProfile(let viewModel):
            guard var editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileViewController else {
                fatalError()
            }
            
            editProfileVC.bind(viewModel: viewModel)
            
            return editProfileVC
        }
    }
}
