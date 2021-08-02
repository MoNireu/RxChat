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
    @IBOutlet weak var profileImageSetButton: UIButton!
    @IBOutlet weak var profilePlusImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5
        
        profilePlusImageView.clipsToBounds = true
        profilePlusImageView.layer.cornerRadius = profilePlusImageView.frame.size.height * 0.5
        
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
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        
        profileImageSetButton.rx.tap
            .subscribe(onNext: { _ in
                self.viewModel.profileImageChanged = true
                self.viewModel.uploadingProfile.onNext(true)
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = .photoLibrary
                imgPicker.mediaTypes = ["public.image"]
                imgPicker.allowsEditing = true
                self.present(imgPicker, animated: true) {
                    self.viewModel.uploadingProfile.onNext(false)
                }
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
        
        completeButton.rx.action = viewModel.profileEditDone
        
    }
}


extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.ownerInfo.profileImg = image
            viewModel.ownerProfileImg.onNext(image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
