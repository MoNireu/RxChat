//
//  PrivateChatListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit

class PrivateChatListViewController: UIViewController, ViewModelBindableType {
    var viewModel: PrivateChatListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        print("PrivateChatList Binded!")
    }
}
