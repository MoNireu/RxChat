//
//  FriendListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Action

class FriendListViewController: UIViewController, ViewModelBindableType {
    
    var disposeBag = DisposeBag()
    var viewModel: FriendListViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var findUserButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.sizeToFit()
    }
    
    func bindViewModel() {
        
        viewModel.profileInfoSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
                
        findUserButton.rx.action = viewModel.presentFindUserView
        
        signOutButton.rx.action = viewModel.signOut
        
        tableView.rx.itemDeleted
            .bind(to: viewModel.deleteFriendAt.inputs)
            .disposed(by: disposeBag)
    
        
        
        tableView.rx.itemSelected
            .bind(to: viewModel.chatFriendAt.inputs)
            .disposed(by: disposeBag)
        
        
        viewModel.isTransToChatRoomComplete
            .subscribe(onNext: { indexPath in
                self.tableView.cellForRow(at: indexPath)?.isSelected = false
            })
            .disposed(by: disposeBag)
    }
}
