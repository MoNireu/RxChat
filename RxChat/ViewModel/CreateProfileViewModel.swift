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
    let isUploadingProfileSubject = BehaviorSubject<Bool>(value: false)
    var profileImageChanged = false
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        print("Create Profile View Model Load")
        Owner.shared.profileImg = UIImage(named: Resources.defaultProfileImg.rawValue)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    deinit {
        print("Log -", #fileID, #function, #line, "DeInit")
    }
    
    lazy var profileEditDone: CocoaAction = {
        return Action { [weak self] _ in
            // start activity indicator
            self?.isUploadingProfileSubject.onNext(true)
            
            self?.firebaseUtil.uploadMyData(isProfileImageChanged: (self?.profileImageChanged)!)
                .subscribe(onNext: { [weak self] uploadedUser in
                    self?.firebaseUtil.uploadProfileUpdateTime(uploadedUser.id!)
                        .subscribe(onCompleted: {
                            Owner.shared.lastFriendListUpdateTime = Timestamp(date: Date())
                            // save last friend list update time on Realm
                            RealmUtil.shared.writeOwner(owner: Owner.shared)
                            // stop acitivy indicator
                            self?.isUploadingProfileSubject.onNext(false)
                            
                            // change to scene "FriendList"
                            let sceneCoordinator = (self?.sceneCoordinator)!
                            let firebaseUtil = (self?.firebaseUtil)!
                            let friendListVM = FriendListViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                            let privateChatListVM = PrivateChatListViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                            let groupChatListVM = GroupChatListViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
                            let chatListScene = Scene.chatList(friendListVM, privateChatListVM, groupChatListVM)
                            self?.sceneCoordinator.transition(to: chatListScene, using: .root, animated: true)
                        }).disposed(by: (self?.disposeBag)!)
                }).disposed(by: (self?.disposeBag)!)
            
            return Observable.empty()
        }
    }()
    
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
