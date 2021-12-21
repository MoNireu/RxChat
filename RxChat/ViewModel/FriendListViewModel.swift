//
//  FriendListViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/27.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import UIKit
import RxDataSources
import GoogleSignIn
import Firebase
import FirebaseAuth


class FriendListViewModel: CommonViewModel {
    
    let myInfo: Owner = Owner.shared
    var profileInfoSubject: BehaviorSubject<[SectionOfUserData]>
    var isTransToChatRoomComplete: BehaviorSubject<IndexPath>
    var disposeBag = DisposeBag()
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfUserData> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SectionOfUserData>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch indexPath.section {
                case 0:
                    let myInfoCell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell", for: indexPath) as! FriendListMyTableViewCell
                    myInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: "defualtProfileImage.png")!
                    myInfoCell.profileName.text = item.id
                    myInfoCell.profileStatMsg.text = "This is test MSG"
                    return myInfoCell
                case 1:
                    let friendInfoCell = tableView.dequeueReusableCell(withIdentifier: "FriendProfileCell", for: indexPath) as! FriendListFriendTableViewCell
                    friendInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: "defualtProfileImage.png")!
                    friendInfoCell.profileName.text = item.id
                    friendInfoCell.profileStatMsg.text = "This is test MSG"
                    return friendInfoCell
                default:
                    return UITableViewCell()
                }
            })
        ds.canEditRowAtIndexPath = { _, _ in return true}
        return ds
    }()
    
    var friendListTableData = [
        SectionOfUserData(uniqueId: "Owner", header: "나", items: [Owner.shared as User]),
        SectionOfUserData(uniqueId: "Friend", header: "친구(\(Owner.shared.friendList.count))", items: Array<User>(Owner.shared.friendList.values))
    ]
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        profileInfoSubject = BehaviorSubject<[SectionOfUserData]>(value: friendListTableData)
        
        dataSource.titleForHeaderInSection = {dataSource, section in
            return dataSource.sectionModels[section].header
        }
        
        isTransToChatRoomComplete = BehaviorSubject<IndexPath>(value: IndexPath(row: 0, section: 0))
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    lazy var presentFindUserView: CocoaAction = {
        return Action { _ in
            let findUserViewModel = FindUserViewModel(friendListDelegate: self, sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
            let findUserScene = Scene.findUser(findUserViewModel)
            self.sceneCoordinator.transition(to: findUserScene, using: .modal, animated: true)
            return Observable.empty()
        }
    }()
    
    
    lazy var signOut: CocoaAction = {
        return Action { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            GIDSignIn.sharedInstance.signOut()
            RealmUtil.shared.deleteAll()
            
            let signInViewModel = SignInViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
            let signInScene = Scene.signIn(signInViewModel)
            self.sceneCoordinator.transition(to: signInScene, using: .root, animated: true)
            return Observable.empty()
        }
    }()
    
    func refresh() {
        setFriendListTableData()
        profileInfoSubject.onNext(friendListTableData)
    }
    
    func setFriendListTableData() {
        friendListTableData = [
            SectionOfUserData(uniqueId: "Owner", header: "나", items: [Owner.shared as User]),
            SectionOfUserData(uniqueId: "Friend", header: "친구(\(Owner.shared.friendList.count))", items: Array<User>(Owner.shared.friendList.values))
        ]
    }
    
    
    lazy var deleteFriendAt: Action<IndexPath, Swift.Never> = {
        return Action { indexPath in
            guard var sections = try? self.profileInfoSubject.value() else {return Observable.empty()}
            
            let currentSection = sections[indexPath.section]
            let deletedFriend = currentSection.items[indexPath.row] as User
            
            print(deletedFriend.email)
            
            return Observable.empty()
        }
    }()
    
    
    lazy var chatFriendAt: Action<IndexPath, Void> = {
        return Action { [self] indexPath in
            guard var sections = try? self.profileInfoSubject.value() else {return Observable.empty()}
            
            let currentSection = sections[indexPath.section]
            let selectedFriend = currentSection.items[indexPath.row] as User
            
            
            // 기존 채팅방이 있는지 확인
            ChatUtility.shared.getPrivateChatRoomUUID(friendId: selectedFriend.id!)
                .subscribe(onNext: { retrivedChatRoomUUID in
                    if let privateChatRoomUUID = retrivedChatRoomUUID {
                        // 기존 채팅방이 있을 경우 해당 채팅방으로 이동
                        let chatRoom: Observable<ChatRoom> = {
                            return Observable.create { observer in
                                let chatRoomObject = RealmUtil.shared.readChatRoom(UUID: privateChatRoomUUID)
                                guard let chatRoomObject = RealmUtil.shared.readChatRoom(UUID: privateChatRoomUUID) else {
                                    ChatUtility.shared.createChatRoomObjectBy(UUID: privateChatRoomUUID, chatRoomType: .privateRoom)
                                        .subscribe(onNext: { chatRoomObject in
                                            observer.onNext(chatRoomObject)
                                        }).disposed(by: self.disposeBag)
                                    return Disposables.create()
                                }
                                observer.onNext(chatRoomObject)
                                return Disposables.create()
                            }
                        }()
                        
                        chatRoom.subscribe(onNext: { chatRoom in
                            let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil, chatRoom: chatRoom)
                            let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                            self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true)
                            isTransToChatRoomComplete.onNext(indexPath)
                            print("Connecting to room number: \(chatRoom.UUID)")
                        }).disposed(by: self.disposeBag)
                    }
                    else {
                        // 기존 채팅룸이 없을 경우 방을 새로 만듬.
                        ChatUtility.shared.createPrivateChatRoom(friendId: selectedFriend.id!)
                            .subscribe(onNext: { chatRoomUUID in
                                // 채팅방으로 이동.
                                ChatUtility.shared.createChatRoomObjectBy(UUID: chatRoomUUID, chatRoomType: .privateRoom)
                                    .subscribe(onNext: { chatRoom in
                                        let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil, chatRoom: chatRoom)
                                        let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                                        self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true)
                                        isTransToChatRoomComplete.onNext(indexPath)
                                        print("Connecting to room number: \(chatRoom.UUID)")
                                    }).disposed(by: self.disposeBag)
                            }).disposed(by: self.disposeBag)
                    }
                }).disposed(by: self.disposeBag)
            return Observable.empty()
        }
    }()
}
