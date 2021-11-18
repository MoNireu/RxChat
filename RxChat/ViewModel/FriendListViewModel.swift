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
import FirebaseAuth


class FriendListViewModel: CommonViewModel {
    
    let myInfo: Owner = Owner.shared
    var profileInfoSubject: BehaviorSubject<[SectionOfUserData]> 
    
//    typealias SectionOfUserData = AnimatableSectionModel<Int, User>
    
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
            
            print(currentSection.items[indexPath.row].email)
            
            return Observable.empty()
        }
    }()
    
    
}
