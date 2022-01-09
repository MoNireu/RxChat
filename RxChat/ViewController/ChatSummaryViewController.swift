//
//  ChatSummaryViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ChatSummaryViewController: UIViewController, ViewModelBindableType {
    
    let CONTENT_HEIGHT: CGFloat = 500
    var viewModel: ChatSummaryViewModel!
    
    let profileImageViewTap = UITapGestureRecognizer()
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showChatBtn: UIButton!
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        editProfileImageButton.isHidden = true
        profileImageView.addGestureRecognizer(profileImageViewTap)
        profileImageView.layer.cornerRadius = profileImageView.frame.height * 0.5
        
        super.viewDidLoad()
    }
    
    override func updateViewConstraints() {
        self.view.frame.origin.y = UIScreen.main.bounds.height - CONTENT_HEIGHT
        self.view.layer.cornerRadius = CONTENT_HEIGHT * 0.03
        super.updateViewConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Log -", #fileID, #function, #line, "View Disappear")
        viewModel.sceneCoordinator.closed()
    }
    
    func bindViewModel() {
        viewModel.userDriver
            .drive(onNext: { [weak self] user in
                if user.id! == Owner.shared.id { self?.editProfileImageButton.isHidden = false }
                self?.profileImageView.image = user.profileImg
                self?.nameLbl.text = user.name
            }).disposed(by: rx.disposeBag)
        
        profileImageViewTap.rx.event.bind { [weak self] _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "기본 이미지 선택", style: .default) { _ in
                let defaultImage = UIImage(named: Resources.defaultProfileImg.rawValue)
                Owner.shared.profileImg = defaultImage
                self?.profileImageView.image = defaultImage
            })
            alert.addAction(UIAlertAction(title: "나의 앨범에서 선택", style: .default) { _ in
//                self?.viewModel.isUploadingProfileSubject.onNext(true)
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = .photoLibrary
                imgPicker.mediaTypes = ["public.image"]
                imgPicker.allowsEditing = true
                self?.present(imgPicker, animated: true) {
//                    self?.viewModel.isUploadingProfileSubject.onNext(false)
                }
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            self?.present(alert, animated: true)
        }.disposed(by: rx.disposeBag)
        
        
        showChatBtn.rx.action = viewModel.chatFriend
    }
}



extension ChatSummaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            Owner.shared.profileImg = image
            profileImageView.image = image
            viewModel.firebaseUtil.uploadProfileImage(Owner.shared.id!, image).subscribe(onNext: { _ in
                print("Log -", #fileID, #function, #line, "profile successfully changed.")
            }).disposed(by: rx.disposeBag)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

