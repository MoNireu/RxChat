//
//  ChatRoomViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/11/26.
//

import UIKit

class ChatRoomViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: ChatRoomViewModel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.sceneCoordinator.closed()
    }

    func bindViewModel() {
        return
    }

}
