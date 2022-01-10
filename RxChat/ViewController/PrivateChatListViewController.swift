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
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.sceneCoordinator.changeTab(index: 1)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.sizeToFit()
        
        viewModel.refreshTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    func bindViewModel() {
        viewModel.tableDataSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.tableDataSubject
            .subscribe(onNext: { val in
                print("Log -", #fileID, #function, #line, val)
            }).disposed(by: rx.disposeBag)
        
        searchController.searchBar.rx.text
            .orEmpty
            .bind(to: viewModel.querySubject)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(ChatRoom.self)
            .bind(to: viewModel.presentChatRoom.inputs)
            .disposed(by: rx.disposeBag)
    }
}
