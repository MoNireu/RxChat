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
    var profileImageChanged = false
    
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
            self.firebaseUtil.uploadOwnerData(self.ownerInfo, uploadProfileImage: self.profileImageChanged)
                .subscribe(onNext: { uploadedUser in
                    self.uploadingProfile.onNext(false)
                    
                    let friendListVM = FriendListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                    let privateChatListVM = PrivateChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                    let groupChatListVM = GroupChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                    let chatListScene = Scene.chatList(friendListVM, privateChatListVM, groupChatListVM)
                    self.sceneCoordinator.transition(to: chatListScene, using: .fullScreen, animated: true)
                })
            
            return Observable.empty()
        }
    }()
    
    
    
}
