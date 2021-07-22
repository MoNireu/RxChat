//
//  EditProfileViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/13.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import Firebase
import RxFirebase

class EditProfileViewModel: CommonViewModel {
    let disposeBag = DisposeBag()
    
    var ownerInfo: User
    var ownerID: BehaviorSubject<String>
    var ownerProfileImg: BehaviorSubject<UIImage>
    let uploadingProfile = BehaviorSubject<Bool>(value: false)
    
    init(ownerInfo: User, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.ownerInfo = ownerInfo
        ownerID = BehaviorSubject<String>(value: ownerInfo.id ?? "")
        
        let profileImg: UIImage
        if let profileImgData = ownerInfo.profileImgData { profileImg = UIImage(data: profileImgData)! }
        else { profileImg = UIImage(named: "defaultProfileImage.png")! }
        
        self.ownerProfileImg = BehaviorSubject<UIImage>(value: profileImg)
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    lazy var profileEditDone: CocoaAction = {
        return Action { _ in
            self.uploadingProfile.onNext(true)
            self.firebaseUtil.uploadOwnerData(self.ownerInfo)
                .subscribe(onNext: { uploadedUser in
                    self.uploadingProfile.onNext(false)
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Profile Edit Done!")
                    print(uploadedUser.email)
                    print(uploadedUser.id)
                    print(uploadedUser.profileImgData)
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                })
            
            return Observable.empty()
        }
    }()
    
    
    
}
