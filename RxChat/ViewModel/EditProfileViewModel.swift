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
    
    var myInfo: Owner = Owner.shared
    var myId: BehaviorSubject<String>
    var myProfileImg: BehaviorSubject<UIImage>
    let uploadingProfile = BehaviorSubject<Bool>(value: false)
    var profileImageChanged = false
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        myId = BehaviorSubject<String>(value: myInfo.id ?? "")
        
        var profileImg: UIImage
        if let _profileImg = myInfo.profileImg { profileImg = _profileImg }
        else { profileImg = UIImage(named: "defaultProfileImage.png")! }
        
        self.myProfileImg = BehaviorSubject<UIImage>(value: profileImg)
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    lazy var profileEditDone: CocoaAction = {
        return Action { _ in
            // start activity indicator
            self.uploadingProfile.onNext(true)
            // upload my data & profile image
            self.firebaseUtil.uploadMyData(self.myInfo, isProfileImageChanged: self.profileImageChanged)
                .subscribe(onNext: { uploadedUser in
                    // upload profile update time
                    self.firebaseUtil.uploadProfileUpdateTime(uploadedUser.email)
                        .subscribe(onCompleted: {
                            // save last friend list update time on Realm
                            Owner.shared.lastFriendListUpdateTime = Timestamp(date: Date())
                            RealmUtil().writeOwner(owner: Owner.shared)
                            // stop acitivy indicator
                            self.uploadingProfile.onNext(false)
                            
                            // change to scene "FriendList"
                            let friendListVM = FriendListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let privateChatListVM = PrivateChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let groupChatListVM = GroupChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let chatListScene = Scene.chatList(friendListVM, privateChatListVM, groupChatListVM)
                            self.sceneCoordinator.transition(to: chatListScene, using: .fullScreen, animated: true)
                        }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            
            return Observable.empty()
        }
    }()
    
    
    
}
