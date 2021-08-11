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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        
        addFriendButton.clipsToBounds = true
        addFriendButton.layer.cornerRadius = addFriendButton.frame.size.height * 0.35
        
        noResultLabel.isHidden = true
        noResultView.isHidden = false
    }
    
    func bindViewModel() {
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { _ in
                self.noResultLabel.isHidden = true
            }).disposed(by: disposeBag)
        
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { _ in
                guard let text = self.searchBar.text else { return }
                self.viewModel.findUser.execute(text)
                    .subscribe(onNext: { user in
                        if let user = user {
                            self.noResultView.isHidden = true
                            self.noResultLabel.isHidden = true
                            self.profileImageView.image = user.profileImg
                            self.nameLabel.text = user.id
                        }
                        else {
                            self.noResultView.isHidden = false
                            self.noResultLabel.isHidden = false
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}
