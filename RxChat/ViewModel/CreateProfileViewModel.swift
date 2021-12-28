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

class CreateProfileViewModel: CommonViewModel {
    let disposeBag = DisposeBag()
    
    var myInfo: Owner = Owner.shared
    var myId: BehaviorSubject<String>
    var myProfileImg: BehaviorSubject<UIImage>
    //    var userAlreadyExist = true
    var userAlreadyExistSubject: BehaviorSubject<Bool>
    let uploadingProfile = BehaviorSubject<Bool>(value: false)
    var profileImageChanged = false
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        print("Create Profile View Model Load")
        myId = BehaviorSubject<String>(value: myInfo.id ?? "")
        userAlreadyExistSubject = BehaviorSubject<Bool>(value: true)
        
        var profileImg: UIImage
        if let _profileImg = myInfo.profileImg { profileImg = _profileImg }
        else { profileImg = UIImage(named: "defaultProfileImage.png")! }
        
        self.myProfileImg = BehaviorSubject<UIImage>(value: profileImg)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        
        onValueChange()
    }
    
    lazy var profileEditDone: CocoaAction = {
        return Action { _ in
            // start activity indicator
            self.uploadingProfile.onNext(true)
            // upload my data & profile image
            self.firebaseUtil.uploadMyData(self.myInfo, isProfileImageChanged: self.profileImageChanged)
                .subscribe(onNext: { uploadedUser in
                    // upload profile update time
                    self.firebaseUtil.uploadProfileUpdateTime(uploadedUser.id!)
                        .subscribe(onCompleted: {
                            // save last friend list update time on Realm
                            Owner.shared.lastFriendListUpdateTime = Timestamp(date: Date())
                            RealmUtil.shared.writeOwner(owner: Owner.shared)
                            // stop acitivy indicator
                            self.uploadingProfile.onNext(false)
                            
                            // change to scene "FriendList"
                            let friendListVM = FriendListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let privateChatListVM = PrivateChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let groupChatListVM = GroupChatListViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
                            let chatListScene = Scene.chatList(friendListVM, privateChatListVM, groupChatListVM)
                            self.sceneCoordinator.transition(to: chatListScene, using: .root, animated: true)
                        }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            
            return Observable.empty()
        }
    }()
    
    func onValueChange() {
        myId.subscribe(onNext: { id in
            self.myInfo.id = id
            
        }).disposed(by: self.disposeBag)
        
    }
    
    func doesUserAlreadyExist(id: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.firebaseUtil.findUser(id)
                .subscribe(onNext: { _ in
                    observer.onNext(true)
                }, onError: { _ in
                    observer.onNext(false)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
}
