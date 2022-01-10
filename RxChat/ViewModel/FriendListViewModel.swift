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
import SwiftUI


class FriendListViewModel: CommonViewModel {
    
    let myInfo: Owner = Owner.shared
    var profileInfoSubject: BehaviorSubject<[SectionOfUserData]>
    var isTransToChatRoomComplete: BehaviorSubject<IndexPath>
    var isChatSummaryPresenting: PublishSubject<Bool>
    let searchController: UISearchController
    var friendListItems: [User]
    var filteredFriendList: [User]
    var friendListTableData: [SectionOfUserData]!
    var disposeBag = DisposeBag()
    
    let dataSource: RxTableViewSectionedReloadDataSource<SectionOfUserData> = {
        let ds = RxTableViewSectionedReloadDataSource<SectionOfUserData>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch indexPath.section {
                case 0:
                    let myInfoCell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCell", for: indexPath) as! FriendListMyTableViewCell
                    myInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: Resources.defaultProfileImg.rawValue)!
                    print("Log -", #fileID, #function, #line, item.profileImg)
                    myInfoCell.profileName.text = item.name
                    myInfoCell.profileStatMsg.text = ""
                    return myInfoCell
                case 1:
                    let friendInfoCell = tableView.dequeueReusableCell(withIdentifier: "FriendProfileCell", for: indexPath) as! FriendListFriendTableViewCell
                    friendInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: Resources.defaultProfileImg.rawValue)!
                    friendInfoCell.profileName.text = item.name
                    friendInfoCell.profileStatMsg.text = ""
                    return friendInfoCell
                default:
                    return UITableViewCell()
                }
            })
        ds.canEditRowAtIndexPath = { _, indexPath in
            // 나의 프로필일 경우 편집을 제한함.
            guard indexPath.section != 0 else {return false}
            return true
        }
        return ds
    }()
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.isTransToChatRoomComplete = BehaviorSubject<IndexPath>(value: IndexPath(row: 0, section: 0))
        self.isChatSummaryPresenting = PublishSubject<Bool>()
        self.searchController = UISearchController()
        self.friendListItems = Array<User>(Owner.shared.friendList.values)
        self.filteredFriendList = friendListItems
        self.profileInfoSubject = BehaviorSubject<[SectionOfUserData]>(value: [])
        self.dataSource.titleForHeaderInSection = { dataSource, section in
            return dataSource.sectionModels[section].header
        }
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        initSearchController()
        observeIsChatSummaryPresenting()
    }
    
    private func initSearchController() {
        self.searchController.searchBar.placeholder = "친구 검색"
        self.searchController.automaticallyShowsCancelButton = true
        self.searchController.hidesNavigationBarDuringPresentation = true
        
        self.searchController.searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { query in
                if query.isEmpty { self.filteredFriendList = self.friendListItems }
                else { self.filteredFriendList = self.friendListItems.filter({$0.name!.contains(query)}) }
                self.refresh()
            }).disposed(by: self.disposeBag)
    }
    
    
    lazy var presentFindUserView: CocoaAction = {
        return Action { [weak self] _ in
            let findUserViewModel = FindUserViewModel(friendListDelegate: self!, sceneCoordinator: self!.sceneCoordinator, firebaseUtil: self!.firebaseUtil)
            let findUserScene = Scene.findUser(findUserViewModel)
            self?.sceneCoordinator.transition(to: findUserScene, using: .modal, animated: true)
            return Observable.empty()
        }
    }()
    
    lazy var presentGroupChatMemberSelectView: CocoaAction = {
        return Action { [weak self] _ in
            let groupChatMemberSelectViewModel = CreateGroupChatViewModel(sceneCoordinator: self!.sceneCoordinator, firebaseUtil: self!.firebaseUtil)
            let groupChatMemberSelectScene = Scene.groupChatMemberSelect(groupChatMemberSelectViewModel)
            self?.sceneCoordinator.transition(to: groupChatMemberSelectScene, using: .modal, animated: true)
            return Observable.empty()
        }
    }()
    
    func refresh() {
        filteredFriendList.sort(by: {$0.name! < $1.name!})
        
        friendListTableData = [
            SectionOfUserData(header: "친구(\(Owner.shared.friendList.count))", items: filteredFriendList)
        ]
            
        if !queryExist() {
            let ownerSectionData = SectionOfUserData(header: "나", items: [myInfo])
            friendListTableData.insert(ownerSectionData, at: 0)
        }
        
        profileInfoSubject.onNext(friendListTableData)
    }
    
    private func queryExist() -> Bool {
        return searchController.searchBar.text!.isEmpty ? false : true
    }
    
    private func observeIsChatSummaryPresenting() {
        isChatSummaryPresenting.subscribe(onNext: { [weak self] isPresenting in
            if !isPresenting {
                self?.refresh()
            }
        }).disposed(by: self.disposeBag)
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
        return Action { [weak self] indexPath in
            guard let self = self else { return Observable.empty() }
            guard var sections = try? self.profileInfoSubject.value() else {return Observable.empty()}
            
            let currentSection = sections[indexPath.section]
            let selectedFriend = currentSection.items[indexPath.row] as User
            
            let chatSummaryViewModel = ChatSummaryViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil, user: selectedFriend)
            chatSummaryViewModel.isChatSummaryPresenting = self.isChatSummaryPresenting
            let chatSummaryScene = Scene.chatSummary(chatSummaryViewModel)
            self.sceneCoordinator.transition(to: chatSummaryScene, using: .fullScreen, animated: true)
            
            self.isChatSummaryPresenting.onNext(true)
            self.isTransToChatRoomComplete.onNext(indexPath)

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
            ChatUtility.shared.removeAllRoomListener()
            ChatUtility.shared.removeAllChatListener()
            
            let signInViewModel = SignInViewModel(sceneCoordinator: self.sceneCoordinator, firebaseUtil: self.firebaseUtil)
            let signInScene = Scene.signIn(signInViewModel)
            self.sceneCoordinator.transition(to: signInScene, using: .root, animated: true)
            return Observable.empty()
        }
    }()
}
