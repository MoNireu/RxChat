//
//  GroupChatListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit

class GroupChatListViewController: UIViewController, ViewModelBindableType {
    var viewModel: GroupChatListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        print("GroupChatList Binded!")
    }

}
