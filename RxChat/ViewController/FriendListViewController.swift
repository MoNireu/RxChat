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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.sizeToFit()
    }
    
    func bindViewModel() {
        print("FriendList Binded!")
        
        viewModel.profileInfoSubject
            .bind(to: tableView.rx.items) { tableView, row, info in
                
                switch row {
                case 0:
                    let myInfoCell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell") as! FriendListMyTableViewCell
                    myInfoCell.profileImageView.image = info.profileImg
                    myInfoCell.profileName.text = info.id
                    myInfoCell.profileStatMsg.text = "This is test MSG"
                    
                    return myInfoCell
                default:
                    let friendInfoCell = tableView.dequeueReusableCell(withIdentifier: "FriendProfileCell") as! FriendListFriendTableViewCell
                    friendInfoCell.profileImageView.image = info.profileImg
                    friendInfoCell.profileName.text = info.id
                    friendInfoCell.profileStatMsg.text = "This is test MSG"
                    
                    return friendInfoCell
                }
                
            }.disposed(by: disposeBag)
        
        
        
        
        
    }
}
