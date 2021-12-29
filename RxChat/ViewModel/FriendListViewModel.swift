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
    var friendListTableData: [SectionOfUserData]!
    var disposeBag = DisposeBag()
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfUserData> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SectionOfUserData>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch indexPath.section {
                case 0:
                    let myInfoCell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell", for: indexPath) as! FriendListMyTableViewCell
                    myInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: Resources.defaultProfileImg.rawValue)!
                    myInfoCell.profileName.text = item.name
                    myInfoCell.profileStatMsg.text = "This is test MSG"
                    return myInfoCell
                case 1:
                    let friendInfoCell = tableView.dequeueReusableCell(withIdentifier: "FriendProfileCell", for: indexPath) as! FriendListFriendTableViewCell
                    friendInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: Resources.defaultProfileImg.rawValue)!
                    friendInfoCell.profileName.text = item.name
                    friendInfoCell.profileStatMsg.text = "This is test MSG"
                    return friendInfoCell
                default:
                    return UITableViewCell()
                }
            })
        ds.canEditRowAtIndexPath = { _, _ in return true}
        return ds
    }()
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        profileInfoSubject = BehaviorSubject<[SectionOfUserData]>(value: [])
        dataSource.titleForHeaderInSection = { dataSource, section in
            return dataSource.sectionModels[section].header
        }
        isTransToChatRoomComplete = BehaviorSubject<IndexPath>(value: IndexPath(row: 0, section: 0))
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        self.refresh()
    }
    
    
    lazy var presentFindUserView: CocoaAction = {
        return Action { _ in
            let findUserViewModel = FindUserViewModel(friendListDelegate: self, sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
            let findUserScene = Scene.findUser(findUserViewModel)
            self.sceneCoordinator.transition(to: findUserScene, using: .modal, animated: true)
            return Observable.empty()
        }
    }()

    
    func refresh() {
        friendListTableData = [
            SectionOfUserData(uniqueId: "Owner", header: "나", items: [Owner.shared as User]),
            SectionOfUserData(uniqueId: "Friend", header: "친구(\(Owner.shared.friendList.count))", items: Array<User>(Owner.shared.friendList.values))
        ]
        profileInfoSubject.onNext(friendListTableData)
    }
    
    
    lazy var deleteFriendAt: Action<IndexPath, Swift.Never> = {
        return Action { indexPath in
            guard var sections = try? self.profileInfoSubject.value() else {return Observable.empty()}
            
            let currentSection = sections[indexPath.section]
            let deletedFriend = currentSection.items[indexPath.row] as User
            
            print("Log -", #fileID, #function, #line, deletedFriend.email)
            
            return Observable.empty()
        }
    }()
    
    
    lazy var selectFriendAt: Action<IndexPath, Void> = {
        return Action { [self] indexPath in
            guard var sections = try? self.profileInfoSubject.value() else {return Observable.empty()}
            
            let currentSection = sections[indexPath.section]
            let selectedFriend = currentSection.items[indexPath.row] as User
            
            
            let chatSummaryViewModel = ChatSummaryViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil, user: selectedFriend)
            let chatSummaryScene = Scene.chatSummary(chatSummaryViewModel)
            sceneCoordinator.transition(to: chatSummaryScene, using: .modal, animated: true)
            
            isTransToChatRoomComplete.onNext(indexPath)

            return Observable.empty()
        }
    }()
    
    func transitionToChat() {
        
    }
    
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
            ChatUtility.shared.removeAllRoomListener()
            ChatUtility.shared.removeAllChatListener()
            
            let signInViewModel = SignInViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
            let signInScene = Scene.signIn(signInViewModel)
            self.sceneCoordinator.transition(to: signInScene, using: .root, animated: true)
            return Observable.empty()
        }
    }()
}
