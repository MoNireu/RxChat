//
//  FriendListViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import UIKit
import RxSwift
import RxCocoa

class FriendListViewController: UIViewController, ViewModelBindableType {
    
    var disposeBag = DisposeBag()
    var viewModel: FriendListViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var findUserButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.sizeToFit()
    }
    
    func bindViewModel() {
        
        viewModel.profileInfoSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
                
        findUserButton.rx.action = self.viewModel.presentFindUserView
    }
}
