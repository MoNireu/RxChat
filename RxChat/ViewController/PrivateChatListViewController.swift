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
        print("Log -", #fileID, #function, #line, "Appear")
        self.viewModel.refreshTable()
        viewModel.chatByRoomIdSubject.subscribe(onNext: { val in
            print("Log -", #fileID, #function, #line, val)
            self.viewModel.refreshTable()
        }).disposed(by: rx.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.chatByRoomIdSubject.disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        viewModel.tableDataSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.tableDataSubject
            .subscribe(onNext: { val in
                print("Log -", #fileID, #function, #line, val)
            })
    }
}
