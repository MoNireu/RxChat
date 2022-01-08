//
//  GroupChatMemberSelectViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/31.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class CreateGroupChatViewController: UIViewController, ViewModelBindableType {
    var viewModel: CreateGroupChatViewModel!
    
    @IBOutlet weak var titleLbl: UINavigationItem!
    @IBOutlet weak var warnLbl: UILabel!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
        
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.sceneCoordinator.closed()
    }
    
    func bindViewModel() {
        
        viewModel.memberCountRelay
            .subscribe(onNext: { [weak self] amount in
                self?.titleLbl.title = "인원 선택(\(amount)명)"
                self?.warnLbl.isHidden = (amount == 0) ? false : true
                self?.nextBtn.isEnabled = (amount > 1) ? true: false
            }).disposed(by: rx.disposeBag)
        
        viewModel.friendListSubject
            .bind(to: tableView.rx.items(dataSource: viewModel.tableDataSource))
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(User.self)
            .bind(to: viewModel.friendSelected.inputs)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelDeselected(User.self)
            .bind(to: viewModel.friendDeselected.inputs)
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.modelSelected(User.self)
            .bind(to: viewModel.memberSelected.inputs)
            .disposed(by: rx.disposeBag)
        
        viewModel.memberListSubject
            .bind(to: collectionView.rx.items(dataSource: viewModel.collectionDataSource))
            .disposed(by: rx.disposeBag)
        
        viewModel.indexOfRemovedMemberRelay
            .subscribe(onNext: { [weak self] row in
                guard let row = row else { return }
                self?.tableView.cellForRow(at: row)?.isSelected = false
            }).disposed(by: rx.disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                self.viewModel.friendQueryedList = {
                    if query.isEmpty {
                        return self.viewModel.friendList
                    }
                    else {
                        return self.viewModel.friendList.filter({$0.name!.contains(query)})
                    }
                }()
                self.viewModel.friendListSubject.onNext([SectionOfUserData(items: self.viewModel.friendQueryedList)])
            }).disposed(by: rx.disposeBag)
        
        nextBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let alert = UIAlertController(title: "방 이름 설정", message: "단체 채팅방의 이름을 설정해주세요.", preferredStyle: .alert)
                alert.addTextField(configurationHandler: {$0.placeholder = "방 이름 입력."})
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                let create = UIAlertAction(title: "만들기", style: .default) { [weak self] _ in
                    guard let roomTitle = alert.textFields?.first?.text else {return}
                    self?.viewModel.createGroupChat.execute(roomTitle)
                        .subscribe(onNext: { [weak self] chatRoom in
                            self?.viewModel.presentChatRoom(chatRoom)
                        }).disposed(by: self!.rx.disposeBag)
                }
                alert.addAction(cancel)
                alert.addAction(create)
                self?.present(alert, animated: true)
            }).disposed(by: rx.disposeBag)
    }
}
