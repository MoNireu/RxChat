//
//  GroupChatMemberSelectViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/31.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift
import Action


class CreateGroupChatViewModel: CommonViewModel {
    
    deinit {print("Log -", #fileID, #function, #line, "DeInit")}
    var disposeBag = DisposeBag()
    
    
    let friendList: [User]
    var friendQueryedList: [User] = []
    let friendListSubject: BehaviorSubject<[SectionOfUserData]>
    var memberList: Array<User>
    let memberListSubject: BehaviorSubject<[SectionOfUserData]>
    let indexOfRemovedMemberRelay = BehaviorRelay<IndexPath?>(value: nil)
    let memberCountRelay = BehaviorRelay<Int>(value: 0)
    var tableDataSource: RxTableViewSectionedReloadDataSource<SectionOfUserData>!
    var collectionDataSource: RxCollectionViewSectionedReloadDataSource<SectionOfUserData>!
    
    override init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.memberList = []
        self.memberListSubject = BehaviorSubject<[SectionOfUserData]>(value: [SectionOfUserData(items: memberList)])
        self.friendList = Array(Owner.shared.friendList.values).sorted(by: {$0.name! < $1.name!})
        self.friendListSubject = BehaviorSubject<[SectionOfUserData]>(value: [SectionOfUserData(items: friendList)])
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        self.tableDataSource = initTableDataSource()
        self.collectionDataSource = initCollectionDataSource()
    }
    
    lazy var friendSelected: Action<User, Void> = {
        return Action { [weak self] user in
            guard let self = self else { return Observable.empty() }
            guard !self.memberList.contains(user) else { return Observable.empty() }
            self.memberList.append(user)
            self.memberListSubject.onNext([SectionOfUserData(items: self.memberList)])
            self.memberCountRelay.accept(self.memberList.count)
            return Observable.empty()
        }
    }()
    
    lazy var friendDeselected: Action<User, Void> = {
        return Action { [weak self] user in
            guard let index = self?.memberList.firstIndex(of: user) else {return Observable.empty()}
            self?.memberList.remove(at: index)
            self?.memberListSubject.onNext([SectionOfUserData(items: self!.memberList)])
            self?.memberCountRelay.accept(self!.memberList.count)
            return Observable.empty()
        }
    }()
    
    lazy var memberSelected: Action<User, Void> = {
        return Action { [weak self] user in
            guard user != Owner.shared else { return Observable.empty() }
            guard let addedFriendIndex = self?.memberList.firstIndex(of: user) else {return Observable.empty()}
            guard let friendIndex = self?.friendList.firstIndex(of: user) else {return Observable.empty()}
            
            self?.memberList.remove(at: addedFriendIndex)
            self?.memberListSubject.onNext([SectionOfUserData(items: self!.memberList)])
            self?.indexOfRemovedMemberRelay.accept(IndexPath.init(row: friendIndex, section: 0))
            self?.memberCountRelay.accept(self!.memberList.count)
            return Observable.empty()
        }
    }()
    
    lazy var createGroupChat: Action<String, ChatRoom> = {
        return Action { [weak self] roomTitle in
            return Observable.create { [weak self] observer in
                guard let friendIdList = self?.memberList.map({$0.id!}) else { return Disposables.create() }
                ChatUtility.shared.createNewGroupChatRoomOnFirebase(friendIdList: friendIdList, roomTitle: roomTitle)
                    .subscribe(onNext: { [weak self] chatRoom in
                        observer.onNext(chatRoom)
                    }).disposed(by: self!.disposeBag)
                return Disposables.create()
            }
        }
    }()
    
    
    func presentChatRoom(_ chatRoom: ChatRoom) {
            let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil, chatRoom: chatRoom)
            let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
            sceneCoordinator.transition(to: chatRoomScene, using: .dismissThenPushOnGroupTab, animated: true)
            print("Connecting to room number: \(chatRoom.UUID)")
    }
    
    
    private func initTableDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfUserData> {
        let ds = RxTableViewSectionedReloadDataSource<SectionOfUserData>(
            configureCell: { dataSource, tableView, indexPath, item in
                let friendInfoCell = tableView.dequeueReusableCell(withIdentifier: IdentifierUtil.TableCell.friendProfileSelect, for: indexPath) as! FriendListFriendSelectTableViewCell
                friendInfoCell.profileImageView.image = item.profileImg ?? UIImage(named: Resources.defaultProfileImg.rawValue)!
                friendInfoCell.profileName.text = item.name
                friendInfoCell.profileStatMsg.text = ""
                self.memberListSubject.subscribe(onNext: { _ in
                    let itemSelected = self.memberList.contains(item)
                    friendInfoCell.radioBtn.isEnabled = itemSelected
                }).disposed(by: self.disposeBag)
                
                return friendInfoCell
            })
        return ds
    }
    
    private func initCollectionDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionOfUserData> {
        return RxCollectionViewSectionedReloadDataSource<SectionOfUserData>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let selectedMemberCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierUtil.CollectionCell.groupChatMemberSelect, for: indexPath) as! GroupChatMemberSelectCollectionViewCell
                selectedMemberCell.profileImageView.image = item.profileImg ?? UIImage(named: Resources.defaultProfileImg.rawValue)!
                selectedMemberCell.nameLbl.text = item.name
                return selectedMemberCell
            })
    }
}
