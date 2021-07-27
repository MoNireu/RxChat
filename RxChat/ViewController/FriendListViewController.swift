//
//  FriendListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit

class FriendListViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: FriendListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        print("FriendList Binded!")
    }

}
