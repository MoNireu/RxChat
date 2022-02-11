//
//  ChatSummaryViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/29.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RxDataSources

class ChatSummaryViewModel: CommonViewModel {
    
    var disposeBag = DisposeBag()
    
    let user: User
    let userDriver: Driver<User>
    let groupChatList: [ChatRoom]
    var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfChatRoomData>!
    var isChatSummaryPresenting: PublishSubject<Bool>!
    var isLoading: PublishSubject<Bool>
    var groupChatListSubject: Observable<[SectionOfChatRoomData]>
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, user: User) {
        self.user = user
        self.userDriver = Driver<User>.just(user)
        self.isLoading = PublishSubject<Bool>()
        self.groupChatList = GroupChatListViewModel.chatRoomById.values.filter({$0.members.contains(user.id!)})
        self.groupChatListSubject = Observable.just([SectionOfChatRoomData(header: "", items: groupChatList)])
        
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
        self.dataSource = initCollectionDataSource()
    }
    
    deinit { print("Log -", #fileID, #function, #line, "DeInit")}
    
    lazy var chatFriend: CocoaAction = {
        return CocoaAction { [weak self] _ in
            
            let friendId = (self?.user.id)!
            
            ChatUtility.shared.preparePrivateChatRoomForTransition(friendId: friendId)
                .subscribe(onNext: { [weak self] chatRoom in // 채팅방으로 이동.
                    let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: (self?.sceneCoordinator)!, firebaseUtil: (self?.firebaseUtil)!, chatRoom: chatRoom)
                    let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                    self?.sceneCoordinator.transition(to: chatRoomScene, using: .dismissThenPushOnPrivateTab, animated: true)
                    print("Connecting to room number: \(chatRoom.UUID)")
                }).disposed(by: (self?.disposeBag)!)
            
            return Observable.empty()
        }
    }()
    
    private func initCollectionDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionOfChatRoomData> {
        return RxCollectionViewSectionedReloadDataSource<SectionOfChatRoomData>(
            configureCell: { dataSource, collectionView, indexPath, item in
                switch item.members.count {
                case 1:
                    let chatSummaryGroupChatCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierUtil.CollectionCell.chatSummaryGroupChatOneMemberCell, for: indexPath) as! ChatSummaryGroupChatOneMemberCollectionViewCell
                    chatSummaryGroupChatCell.groupChatImageView1.image = Owner.shared.getUserProfileImage(userId: item.members[0])
                    chatSummaryGroupChatCell.groupChatNameLabel.text = item.title
                    return chatSummaryGroupChatCell
                case 2:
                    let chatSummaryGroupChatCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierUtil.CollectionCell.chatSummaryGroupChatTwoMemberCell, for: indexPath) as! ChatSummaryGroupChatTwoMemberCollectionViewCell
                    chatSummaryGroupChatCell.groupChatImageView1.image = Owner.shared.getUserProfileImage(userId: item.members[0])
                    chatSummaryGroupChatCell.groupChatImageView2.image = Owner.shared.getUserProfileImage(userId: item.members[1])
                    chatSummaryGroupChatCell.groupChatNameLabel.text = item.title
                    return chatSummaryGroupChatCell
                case 3:
                    let chatSummaryGroupChatCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierUtil.CollectionCell.chatSummaryGroupChatThreeMemberCell, for: indexPath) as! ChatSummaryGroupChatThreeMemberCollectionViewCell
                    chatSummaryGroupChatCell.groupChatImageView1.image = Owner.shared.getUserProfileImage(userId: item.members[0])
                    chatSummaryGroupChatCell.groupChatImageView2.image = Owner.shared.getUserProfileImage(userId: item.members[1])
                    chatSummaryGroupChatCell.groupChatImageView3.image = Owner.shared.getUserProfileImage(userId: item.members[2])
                    chatSummaryGroupChatCell.groupChatNameLabel.text = item.title
                    return chatSummaryGroupChatCell
                default:
                    let chatSummaryGroupChatCell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierUtil.CollectionCell.chatSummaryGroupChatFourMemberCell, for: indexPath) as! ChatSummaryGroupChatFourMemberCollectionViewCell
                    chatSummaryGroupChatCell.groupChatImageView1.image = Owner.shared.getUserProfileImage(userId: item.members[0])
                    chatSummaryGroupChatCell.groupChatImageView2.image = Owner.shared.getUserProfileImage(userId: item.members[1])
                    chatSummaryGroupChatCell.groupChatImageView3.image = Owner.shared.getUserProfileImage(userId: item.members[2])
                    chatSummaryGroupChatCell.groupChatImageView4.image = Owner.shared.getUserProfileImage(userId: item.members[3])
                    chatSummaryGroupChatCell.groupChatNameLabel.text = item.title
                    return chatSummaryGroupChatCell
                }
            })
    }
    
}
