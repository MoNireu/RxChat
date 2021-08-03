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
        
        viewModel.myInfoSubject
            .bind(to: tableView.rx.items) { tableView, row, info in
                if let myInfoCell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell") as? FriendListMyTableViewCell {
                    myInfoCell.myProfileImageView.image = info.profileImg
                    myInfoCell.myProfileName.text = info.id
                    myInfoCell.myProfileStatMsg.text = "This is test MSG"

                    return myInfoCell
                }
                return UITableViewCell()
            }
    }
}
