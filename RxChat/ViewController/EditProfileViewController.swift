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
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        
        idTextField.placeholder = "닉네임을 입력하세요"
        idTextField.textAlignment = .center
        
        completeButton.layer.cornerRadius = completeButton.frame.size.height * 0.35
    }
    
    func bindViewModel() {
        viewModel.ownerID
            .subscribe(onNext: { id in
                self.idTextField.text = id
            })
            .dispose()
        
        viewModel.ownerProfileImg
            .subscribe(onNext: { image in
                self.profileImageView.image = image
            })
            .disposed(by: disposeBag)
        
        idTextField.rx.text
            .subscribe(onNext: { id in
                self.viewModel.ownerInfo.id = id
                self.viewModel.ownerID.onNext(id ?? "")
            })
            .disposed(by: disposeBag)
        

        viewModel.uploadingProfile
            .subscribe(onNext: { isUploading in
                self.actIndicator.isHidden = !isUploading
            })
            .disposed(by: disposeBag)
        
        completeButton.rx
            .bind(to: viewModel.profileEditDone, input: profileImageView.image!)
    }
}
