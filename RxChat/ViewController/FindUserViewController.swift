//
//  FindUserViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa


enum AddFriendButtonState {
    case myProfile
    case alreadyFriend
    case addFriend
}

class FindUserViewController: UIViewController, ViewModelBindableType {
    var viewModel: FindUserViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var modalBar: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        
        addFriendButton.clipsToBounds = true
        addFriendButton.layer.cornerRadius = addFriendButton.frame.size.height * 0.35
        addFriendButton.setBackgroundColor(UIColor.systemBlue, for: .normal)
        addFriendButton.setBackgroundColor(UIColor.systemGray, for: .disabled)
        
        
        modalBar.clipsToBounds = true
        modalBar.layer.cornerRadius = modalBar.frame.size.height * 0.5
        
        noResultLabel.isHidden = true
        noResultView.isHidden = false
        
        self.activityIndicator.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.friendListDelegate.refresh()
        viewModel.sceneCoordinator.closed()
        print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
        print("refresh")
        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
    }
    
    // MARK: Bind View
    func bindViewModel() {
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self]_ in
                self?.noResultLabel.isHidden = true
            }).disposed(by: disposeBag)
        
        addFriendButton.rx.tap
            .subscribe(onNext: { [weak self]_ in
                self?.activityIndicator.startAnimating()
                self?.viewModel.addFriend.execute()
                    .subscribe(onCompleted: {
                        self?.activityIndicator.stopAnimating()
                        let alert = UIAlertController(title: "친구추가를 완료했습니다.", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
                            self?.changeAddFriendButtonState(state: .alreadyFriend)
                        })
                        self?.present(alert, animated: true)
                    }).disposed(by: self!.disposeBag)
            }).disposed(by: self.disposeBag)
        
        
        viewModel.foundUserSubject
            .subscribe(onNext: { [weak self] user in
                self?.activityIndicator.stopAnimating()
                // user found
                if let user = user {
                    self?.hideNoResultView(true)
                    self?.profileImageView.image = user.profileImg
                    self?.nameLabel.text = user.name
                    // found user is owner
                    if user.id == Owner.shared.id {
                        self?.changeAddFriendButtonState(state: .myProfile)
                    }
                    // found user is already friend
                    else if Owner.shared.friendList.keys.contains(user.id!) {
                        self?.changeAddFriendButtonState(state: .alreadyFriend)
                    }
                    // found user is not friend
                    else {
                        self?.changeAddFriendButtonState(state: .addFriend)
                    }
                }
                // user not found
                else {
                    self?.hideNoResultView(false)
                }
            }).disposed(by: disposeBag)
        
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self]_ in
                self?.searchBar.resignFirstResponder()
                self?.activityIndicator.startAnimating()
                guard let text = self?.searchBar.text else { return }
                self?.viewModel.findUser.execute(text)
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: ViewControl Methods
    func hideNoResultView(_ hide: Bool) {
        self.noResultView.isHidden = hide
        self.noResultLabel.isHidden = hide
    }
    
    func changeAddFriendButtonState(state: AddFriendButtonState) {
        switch state {
        case .myProfile:
            self.addFriendButton.setTitle("나의 프로필 입니다", for: .disabled)
            self.addFriendButton.isEnabled = false
            return
        case .alreadyFriend:
            self.addFriendButton.setTitle("이미 나의 친구입니다", for: .disabled)
            self.addFriendButton.isEnabled = false
            return
        case .addFriend:
            self.addFriendButton.setTitle("+ 친구추가", for: .normal)
            self.addFriendButton.isEnabled = true
            return
        }
    }
}
