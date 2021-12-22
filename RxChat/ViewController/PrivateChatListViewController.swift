//
//  PrivateChatListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit
import NSObject_Rx

class PrivateChatListViewController: UIViewController, ViewModelBindableType {
    var viewModel: PrivateChatListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Log -", #fileID, #function, #line, "Appear")
        viewModel.userIdByRoomIdSubject.subscribe(onNext: { val in
            print("Log -", #fileID, #function, #line, val)
            self.viewModel.updateLastMessage()
        }).disposed(by: rx.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.userIdByRoomIdSubject.disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        print("PrivateChatList Binded!")
        
    }
}
