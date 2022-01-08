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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.searchController = viewModel.searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.sceneCoordinator.changeTab(index: 0)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.sizeToFit()
    }

    
    func bindViewModel() {
        
        viewModel.profileInfoSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
                
        
        findUserButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                print("Log -", #fileID, #function, #line, "finUserButtonBefor:\(self?.viewModel.sceneCoordinator.getCurrentVC())")
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let findUser = UIAlertAction(title: "친구 찾기", style: .default) { [weak self] _ in
                    self?.viewModel.presentFindUserView.execute()
                }
                let findUserImage = UIImage(systemName: "magnifyingglass")
                findUser.setValue(findUserImage, forKey: "image")
                
                let createGroupChat = UIAlertAction(title: "단체채팅 생성", style: .default) { [weak self] _ in
                    self?.viewModel.presentGroupChatMemberSelectView.execute()
                }
                let createGroupChatImage = UIImage(systemName: "plus.bubble")
                createGroupChat.setValue(createGroupChatImage, forKey: "image")
                
                let signOut = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
                    self?.viewModel.signOut.execute()
                }
                let signOutImage = UIImage(systemName: "rectangle.portrait.and.arrow.right")
                signOut.setValue(signOutImage, forKey: "image")
                
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(findUser)
                alert.addAction(createGroupChat)
                alert.addAction(signOut)
                alert.addAction(cancel)
                self?.present(alert, animated: true) {
                    print("Log -", #fileID, #function, #line, "finUserButtonAfter:\(self?.viewModel.sceneCoordinator.getCurrentVC())")
                }
            }).disposed(by: rx.disposeBag)
        
        
        tableView.rx.itemDeleted
            .bind(to: viewModel.deleteFriendAt.inputs)
            .disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected
            .bind(to: viewModel.selectFriendAt.inputs)
            .disposed(by: disposeBag)
        
        
        viewModel.isTransToChatRoomComplete
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.cellForRow(at: indexPath)?.isSelected = false
            })
            .disposed(by: disposeBag)
    }
}
