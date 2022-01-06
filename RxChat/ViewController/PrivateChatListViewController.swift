//
//  PrivateChatListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class PrivateChatListViewController: UIViewController, ViewModelBindableType {
    var viewModel: PrivateChatListViewModel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.sceneCoordinator.changeTab(index: 1)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.sizeToFit()
        
        print("Log -", #fileID, #function, #line, "Appear")
        viewModel.chatRoomByRoomIdSubject.subscribe(onNext: { val in
            print("Log -", #fileID, #function, #line, val)
            self.viewModel.refreshTable()
        }).disposed(by: rx.disposeBag)
        viewModel.chatRoomByRoomIdSubject.onNext(viewModel.chatRoomByRoomId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.chatRoomByRoomIdSubject.disposed(by: rx.disposeBag)
    }
    
    
    func bindViewModel() {
        viewModel.tableDataSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.tableDataSubject
            .subscribe(onNext: { val in
                print("Log -", #fileID, #function, #line, val)
            }).disposed(by: rx.disposeBag)
    }
}
