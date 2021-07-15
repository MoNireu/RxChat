//
//  EditProfileViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/13.
//

import UIKit
import RxCocoa
import RxSwift
import Action

class EditProfileViewController: UIViewController, ViewModelBindableType {
    
    var disposeBag = DisposeBag()
    var viewModel: EditProfileViewModel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        profileImageView.image = UIImage(named: "defaultProfileImage.png")
        
        idTextField.placeholder = "닉네임을 입력하세요"
        idTextField.textAlignment = .center
        
        completeButton.layer.cornerRadius = completeButton.frame.size.height * 0.35
    }
    
    func bindViewModel() {
        viewModel.ownerInfoSubject
            .subscribe(onNext: { user in
                if let id = user.id {
                    self.idTextField.text = id
                }
            })
            .dispose()
        
        idTextField.rx.text
            .subscribe(onNext: { id in
                self.viewModel.ownerInfo.id = id
                self.viewModel.ownerInfoSubject.onNext(self.viewModel.ownerInfo)
            })
            .disposed(by: disposeBag)
        
        completeButton.rx.action = viewModel.profileEditDone()
    }
    
    
    
    
}
