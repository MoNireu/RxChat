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
            // 기존 채팅방이 있는지 확인
            ChatUtility.shared.getChatRoomIdBy(friendId: friendId, roomType: .privateRoom)
                .subscribe(onNext: { retrivedChatRoomUUID in
                    // ChatRoom Object 가져오기
                    Observable<ChatRoom>.create { observer in
                        guard let privateChatRoomUUID = retrivedChatRoomUUID else { // 기존 채팅방이 없는 경우
                            ChatUtility.shared.createChatRoom(friendId: friendId, roomTitle: friendId)
                                .subscribe(onNext: { chatRoom in
                                    observer.onNext(chatRoom)
                                    observer.onCompleted()
                                }).disposed(by: (self?.disposeBag)!)
                            return Disposables.create()
                        }
                        guard let chatRoomObject = RealmUtil.shared.readChatRoom(UUID: privateChatRoomUUID) else { // Realm에 존재하지 않을경우 Firebase에서 가져오기
                            ChatUtility.shared.getChatRoomBy(roomId: privateChatRoomUUID)
                                .subscribe(onNext: { chatRoomObject in
                                    observer.onNext(chatRoomObject)
                                    observer.onCompleted()
                                }).disposed(by: (self?.disposeBag)!)
                            return Disposables.create()
                        }
                        observer.onNext(chatRoomObject)
                        observer.onCompleted()
                        
                        return Disposables.create()
                    }
                    .subscribe(onNext: { chatRoom in // 채팅방으로 이동.
                        let chatRoomViewModel = ChatRoomViewModel(sceneCoordinator: (self?.sceneCoordinator)!, firebaseUtil: (self?.firebaseUtil)!, chatRoom: chatRoom)
                        let chatRoomScene = Scene.chatRoom(chatRoomViewModel)
                        self?.sceneCoordinator.transition(to: chatRoomScene, using: .pushOnParent, animated: true)
                        print("Connecting to room number: \(chatRoom.UUID)")
                    }).disposed(by: (self?.disposeBag)!)
                }).disposed(by: (self?.disposeBag)!)
            
            
            return Observable.empty()
        }
    }()
}
