//
//  FindUserViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/10.
//

import UIKit

class FindUserViewController: UIViewController, ViewModelBindableType {
    var viewModel: FindUserViewModel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var noResultView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        
        addFriendButton.clipsToBounds = true
        addFriendButton.layer.cornerRadius = addFriendButton.frame.size.height * 0.35
    }
    

    func bindViewModel() {
        
    }
}
