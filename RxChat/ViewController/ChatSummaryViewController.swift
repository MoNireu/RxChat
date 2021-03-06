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
    
    let CORNER_RADIUS: Float = 0.035
    var viewModel: ChatSummaryViewModel!
    
    let profileImageViewTap = UITapGestureRecognizer()
    let backgroundViewTap = UITapGestureRecognizer()
    @IBOutlet weak var foregroundView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showChatBtn: UIButton!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        editProfileImageButton.isHidden = true
        profileImageView.addGestureRecognizer(profileImageViewTap)
        profileImageView.layer.cornerRadius = profileImageView.frame.height * 0.5
        foregroundView.setCornerRadius(value: CORNER_RADIUS)
        backgroundView.addGestureRecognizer(backgroundViewTap)
        showChatBtn.setCornerRadius(value: CORNER_RADIUS)
        actIndicator.stopAnimating()
        super.viewDidLoad()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Log -", #fileID, #function, #line, "View Disappear")
        viewModel.isChatSummaryPresenting.onNext(false)
        viewModel.sceneCoordinator.closed()
    }
    
    func bindViewModel() {
        viewModel.userDriver
            .drive(onNext: { [weak self] user in
                if user.id! == Owner.shared.id { self?.editProfileImageButton.isHidden = false }
                self?.profileImageView.image = user.profileImg
                self?.nameLbl.text = user.name
            }).disposed(by: rx.disposeBag)
        
        viewModel.groupChatListSubject
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        profileImageViewTap.rx.event.bind { [weak self] _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "?????? ????????? ??????", style: .default) { _ in
                let defaultImage = UIImage(named: Resources.defaultProfileImg.rawValue)
                Owner.shared.profileImg = defaultImage
                self?.profileImageView.image = defaultImage
            })
            alert.addAction(UIAlertAction(title: "?????? ???????????? ??????", style: .default) { _ in
                self?.actIndicator.startAnimating()
                let imgPicker = UIImagePickerController()
                imgPicker.delegate = self
                imgPicker.sourceType = .photoLibrary
                imgPicker.mediaTypes = ["public.image"]
                imgPicker.allowsEditing = true
                self?.present(imgPicker, animated: true) {
                    self?.actIndicator.stopAnimating()
                }
            })
            alert.addAction(UIAlertAction(title: "??????", style: .cancel))
            self?.present(alert, animated: true)
        }.disposed(by: rx.disposeBag)
        
        
        backgroundViewTap.rx.event.subscribe { [weak self] _ in
            self?.dismiss(animated: true)
        }.disposed(by: rx.disposeBag)
        
        showChatBtn.rx.action = viewModel.chatFriend
    }
}



extension ChatSummaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            actIndicator.startAnimating()
            Owner.shared.profileImg = image
            profileImageView.image = image
            
            let uploadProfileImage = viewModel.firebaseUtil.uploadProfileImage(Owner.shared.id!, image)
            let uploadProfileUpdateTime = viewModel.firebaseUtil.uploadProfileUpdateTime(Owner.shared.id!)
            
            Observable.zip(uploadProfileImage, uploadProfileUpdateTime)
                .subscribe(onNext: { [weak self] _ in
                    print("Log -", #fileID, #function, #line, "Profile Image and Update time Upload Completed")
                    self?.actIndicator.stopAnimating()
                    picker.dismiss(animated: true)
                }).disposed(by: rx.disposeBag)
        }
        else {
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

