//
//  FindUserViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa

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
        addFriendButton.setTitle("+ 친구추가", for: .normal)
        addFriendButton.setBackgroundColor(UIColor.systemBlue, for: .normal)
        addFriendButton.setBackgroundColor(UIColor.systemGray, for: .disabled)
        
        
        modalBar.clipsToBounds = true
        modalBar.layer.cornerRadius = modalBar.frame.size.height * 0.5
        
        noResultLabel.isHidden = true
        noResultView.isHidden = false
        
        self.activityIndicator.stopAnimating()
    }
    
    func bindViewModel() {
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { _ in
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("text edit started")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                self.noResultLabel.isHidden = true
            }).disposed(by: disposeBag)
        
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { _ in
                self.searchBar.resignFirstResponder()
                self.activityIndicator.startAnimating()
                guard let text = self.searchBar.text else { return }
                self.viewModel.findUser.execute(text)
                    .subscribe(onNext: { user in
                        self.activityIndicator.stopAnimating()
                        if let user = user { // user found
                            self.hideNoResultView(true)
                            self.profileImageView.image = user.profileImg
                            self.nameLabel.text = user.id
                            if user.email == self.viewModel.ownerInfo.email {
                                self.addFriendButton.setTitle("나의 프로필 입니다", for: .disabled)
                                self.addFriendButton.isEnabled = false
                                self.addFriendButton.backgroundColor = UIColor.systemGray
                            }
                            else {
                                self.addFriendButton.titleLabel?.text = "+ 친구추가"
                                self.addFriendButton.isEnabled = true
                            }
                        }
                        else { // user not found
                            self.hideNoResultView(false)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    func hideNoResultView(_ hide: Bool) {
        self.noResultView.isHidden = hide
        self.noResultLabel.isHidden = hide
    }
}
