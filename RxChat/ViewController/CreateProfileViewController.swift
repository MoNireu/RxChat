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
import SwiftUI
import NSObject_Rx


class CreateProfileViewController: UIViewController, ViewModelBindableType {
    
    
    var disposeBag = DisposeBag()
    var viewModel: CreateProfileViewModel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
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
        
        idTextField.placeholder = "아이디는 추후에 변경하실 수 없습니다."
        idTextField.textAlignment = .center
        
        nameTextField.placeholder = "친구들에게 보여질 이름을 설정합니다."
        nameTextField.textAlignment = .center
        
        completeButton.setBackgroundColor(.lightGray, for: .disabled)
        completeButton.clipsToBounds = true
        completeButton.layer.cornerRadius = completeButton.frame.size.height * 0.35
    }
    
    
    func bindViewModel() {
        viewModel.myId
            .subscribe(onNext: { id in
                self.idTextField.text = id
            })
            .dispose()
        
        viewModel.myProfileImg
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        
        profileImageSetButton.rx.tap
            .subscribe(onNext: { _ in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "기본 이미지 선택", style: .default) { _ in
                    self.viewModel.profileImageChanged = true
                    let image = UIImage(named: "defaultProfileImage.png")
                    self.viewModel.myInfo.profileImg = image
                    self.viewModel.myProfileImg.onNext(image!)
                })
                alert.addAction(UIAlertAction(title: "나의 앨범에서 선택", style: .default) {_ in
                    self.viewModel.profileImageChanged = true
                    
                    self.viewModel.isUploadingProfileSubject.onNext(true)
                    let imgPicker = UIImagePickerController()
                    imgPicker.delegate = self
                    imgPicker.sourceType = .photoLibrary
                    imgPicker.mediaTypes = ["public.image"]
                    imgPicker.allowsEditing = true
                    self.present(imgPicker, animated: true) {
                        self.viewModel.isUploadingProfileSubject.onNext(false)
                    }
                })
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        idTextField
            .rx
            .text
            .subscribe(onNext: { [weak self] id in
                self?.viewModel.myId.onNext(id ?? "")
            }).disposed(by: rx.disposeBag)
        
        
        let idTextFieldConfirmedObservable = addIdTextFieldConfirmObservables()
        let nameTextFieldConfirmedObservable = addNameTextFieldConfirmObservables()
        Observable.combineLatest(idTextFieldConfirmedObservable, nameTextFieldConfirmedObservable)
            .subscribe(onNext: { [weak self] in
                self?.completeButton.isEnabled = $0 && $1
            }).disposed(by: rx.disposeBag)

        
        
        let idTextFieldDidBeginEditingObservable = idTextField
            .rx
            .controlEvent(.editingDidBegin)
        let nameTextFieldDidBeginEditingObservable = nameTextField
            .rx
            .controlEvent(.editingDidBegin)
        Observable.of(idTextFieldDidBeginEditingObservable, nameTextFieldDidBeginEditingObservable)
            .merge()
            .subscribe(onNext: { [weak self] _ in
                self?.completeButton.isEnabled = false
            }).disposed(by: rx.disposeBag)
        
        completeButton.rx.action = viewModel.profileEditDone
        
        
        viewModel.isUploadingProfileSubject
            .subscribe(onNext: { [weak self] isUploading in
                self?.actIndicator.isHidden = !isUploading
            })
            .disposed(by: disposeBag)
        
        
        Observable.just(false)
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
    }
    
    private func addIdTextFieldConfirmObservables() -> Observable<Bool> {
        let idTextFieldEditDidEnd = idTextField
            .rx
            .controlEvent(.editingDidEnd)

        let idTextFieldEditDidEndOnExit = idTextField
            .rx
            .controlEvent(.editingDidEndOnExit)
        
        let isIdTextFieldConfirmedObserver = Observable<Bool>.create { [weak self] observer in
            Observable.of(idTextFieldEditDidEnd, idTextFieldEditDidEndOnExit)
                .merge()
                .subscribe(onNext: { [weak self] _ in
                    guard let text = self?.idTextField.text else { observer.onNext(false); return}
                    self?.viewModel.doesUserAlreadyExist(id: text)
                        .subscribe(onNext: { [weak self] userAlreadyExist in
                            if userAlreadyExist {
                                self?.alertIdAlreadyExist()
                                observer.onNext(false)
                            }
                            else { observer.onNext(true) }
                        }).disposed(by: (self?.rx.disposeBag)!)
                }).disposed(by: (self?.rx.disposeBag)!)
            return Disposables.create()
        }
        
        return isIdTextFieldConfirmedObserver
    }
    
    private func addNameTextFieldConfirmObservables() -> Observable<Bool> {
        let nameTextFieldEditDidEnd = nameTextField
            .rx
            .controlEvent(.editingDidEnd)
        
        let nameTextFieldEditDidEndOnExit = nameTextField
            .rx
            .controlEvent(.editingDidEndOnExit)
        
        let isNameTextFieldConfirmedObserver = Observable<Bool>.create { [weak self] observer in
            Observable.of(nameTextFieldEditDidEnd, nameTextFieldEditDidEndOnExit)
                .merge()
                .subscribe { [weak self] _ in
                    guard (self?.nameTextField.text) != nil else {observer.onNext(false); return}
                    observer.onNext(true)
                }.disposed(by: (self?.rx.disposeBag)!)
            return Disposables.create()
        }
        
        return isNameTextFieldConfirmedObserver
    }
    
    private func alertIdAlreadyExist() {
        let alert = UIAlertController(title: "아이디 중복",
                                      message: "이미 존재하는 아이디입니다.\n다른 아이디를 설정해주세요.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "닫기", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}


extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.myInfo.profileImg = image
            viewModel.myProfileImg.onNext(image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
