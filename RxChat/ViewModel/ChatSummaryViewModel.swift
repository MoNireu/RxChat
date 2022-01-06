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

class ChatSummaryViewModel: CommonViewModel {
    
    var disposeBag = DisposeBag()
    
    let user: User
    let userDriver: Driver<User>
    
    init(sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil, user: User) {
        self.user = user
        self.userDriver = Driver<User>.just(user)
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
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
}
