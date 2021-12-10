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
    var disposeBag = DisposeBag()
    lazy var chatUtil = {
        return ChatUtility()
    }()
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfUserData> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SectionOfUserData>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch indexPath.section {
                case 0:
                    let myInfoCell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell", for: indexPath) as! FriendListMyTableViewCell
                    myInfoCell.profileImageView.image = item.profileImg
                    myInfoCell.profileName.text = item.id
                    myInfoCell.profileStatMsg.text = "This is test MSG"
                    return myInfoCell
                case 1:
                    let friendInfoCell = tableView.dequeueReusableCell(withIdentifier: "FriendProfileCell", for: indexPath) as! FriendListFriendTableViewCell
                    friendInfoCell.profileImageView.image = item.profileImg
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
        SectionOfUserData(uniqueId: "Friend", header: "친구(\(Owner.shared.friendList.count))", items: Owner.shared.friendList)
    ]
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        profileInfoSubject = BehaviorSubject<[SectionOfUserData]>(value: friendListTableData)
        
        
        dataSource.titleForHeaderInSection = {dataSource, section in
            return dataSource.sectionModels[section].header
        }
        
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
            RealmUtil().deleteAll()
            
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
            SectionOfUserData(uniqueId: "Friend", header: "친구(\(Owner.shared.friendList.count))", items: Owner.shared.friendList)
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
            chatUtil.getPrivateChatRoomUUID(friendId: selectedFriend.id!)
                .subscribe(onNext: { retrivedChatRoomUUID in
                    if let privateChatRoomUUID = retrivedChatRoomUUID {
                        // 기존 채팅방이 있을 경우 해당 채팅방으로 연결
                        chatUtil.createChatRoomObjectBy(UUID: privateChatRoomUUID, chatRoomType: .privateRoom)
                            .subscribe(onSuccess: { chatRoom in
                                let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil, chatRoom: chatRoom)
                                let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                                self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true)
                                print("Connecting to room number: \(chatRoom.UUID)")
                            }).disposed(by: self.disposeBag)
                    }
                    else {
                        // 기존 채팅룸이 없을 경우 방을 새로 만듬.
                        chatUtil.createPrivateChatRoom(friendId: selectedFriend.id!)
                            .subscribe(onNext: { chatRoomUUID in
                                
                                // 기존 채팅방이 있을 경우 해당 채팅방으로 연결
                                chatUtil.createChatRoomObjectBy(UUID: chatRoomUUID, chatRoomType: .privateRoom)
                                    .subscribe(onSuccess: { chatRoom in
                                        let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil, chatRoom: chatRoom)
                                        let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                                        self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true)
                                        print("Connecting to room number: \(chatRoom.UUID)")
                                    }).disposed(by: self.disposeBag)
                            }).disposed(by: self.disposeBag)
                    }
                }).disposed(by: self.disposeBag)
            return Observable.empty()
        }
    }()
    
    
}


extension String {
    func removeDotFromEmail() -> String {
        return self.replacingOccurrences(of: ".", with: "")
    }
}
