//
//  ChatUtility.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/01.
//

import Foundation
import FirebaseDatabase
import RxFirebaseDatabase
import RxSwift
import NSObject_Rx
import RealmSwift
import SwiftUI


class ChatUtility {
    static let shared = ChatUtility()
    var disposeBag = DisposeBag()
    
    private let _ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/")
    private lazy var usersRef = _ref.reference(withPath: "users")
    private lazy var roomsRef = _ref.reference(withPath: "rooms")
    private lazy var chatsRef = _ref.reference(withPath: "chats")
    let myId = Owner.shared.id!
    
    
    // MARK: - ChatRoom
    var ownerPrivateChatRoomList: [String] = [] // [PrivateRoomUUID]
    var ownerGroupChatRoomList: [String] = [] // [GroupRoomUUID]
    
    
    func createNewPrivateChatRoomOnFirebase(friendId: String, roomTitle: String) -> Observable<ChatRoom> {
        return Observable.create { observer in
            let roomId = UUID().uuidString
            let privateRoom = ChatRoomType.privateRoom
            
            let setRoomIdToOwner = self.setRoomIdToOwner(roomType: privateRoom, value: [friendId: roomId])
            let setRoomIdToFriend = self.setRoomIdToUsers(roomType: privateRoom, friendIdList: [friendId], value: [self.myId: roomId])
            
            Observable.of(setRoomIdToOwner, setRoomIdToFriend)
                .merge()
                .subscribe(onCompleted: {
                    let members = [Owner.shared.id!, friendId]
                    self.setRoomInfo(roomId: roomId, roomType: privateRoom, members: members, roomTitle: roomTitle)
                        .subscribe(onSuccess: { dataRef in
                            print("Log -", #fileID, #function, #line, "Success")
                            let chatRoom = ChatRoom(UUID: roomId,
                                                    title: roomTitle,
                                                    chatRoomType: privateRoom,
                                                    host: self.myId,
                                                    members: members,
                                                    chats: [])
                            observer.onNext(chatRoom)
                        }, onError: { err in
                            print("Log -", #fileID, #function, #line, "Error")
                        }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func createNewGroupChatRoomOnFirebase(friendIdList: [String], roomTitle: String) -> Observable<ChatRoom> {
        return Observable.create { observer in
            let roomId = UUID().uuidString
            let groupRoom = ChatRoomType.groupRoom
            
            let setRoomIdToOwner = self.setRoomIdToOwner(roomType: groupRoom, value: [roomId : roomId])
            let setRoomIdToMembers = self.setRoomIdToUsers(roomType: groupRoom, friendIdList: friendIdList, value: [roomId : roomId])
            
            Observable.of(setRoomIdToOwner, setRoomIdToMembers)
                .merge()
                .subscribe(onCompleted: {
                    let members = ([self.myId] + friendIdList).sorted()
                    self.setRoomInfo(roomId: roomId, roomType: groupRoom, members: members, roomTitle: roomTitle)
                        .subscribe(onSuccess: { dataRef in
                            print("Log -", #fileID, #function, #line, "Success")
                            let chatRoom = ChatRoom(UUID: roomId,
                                                    title: roomTitle,
                                                    chatRoomType: .groupRoom,
                                                    host: self.myId,
                                                    members: members,
                                                    chats: [])
                            observer.onNext(chatRoom)
                        }, onError: { err in
                            print("Log -", #fileID, #function, #line, "Error")
                        }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    private func setRoomIdToOwner(roomType: ChatRoomType, value: [String: String]) -> Single<DatabaseReference> {
        return self.usersRef
            .child(self.myId)
            .child(roomType.rawValue)
            .rx
            .updateChildValues(value)
    }
    
    
    private func setRoomIdToUsers(roomType: ChatRoomType, friendIdList: [String], value: [String: String]) -> Single<DatabaseReference> {
        Single<DatabaseReference>.create { single in
            var cnt = 0
            for friendId in friendIdList {
                self.usersRef
                    .child(friendId)
                    .child(roomType.rawValue)
                    .rx
                    .updateChildValues(value)
                    .subscribe(onSuccess: { ref in
                        cnt += 1
                        if cnt == friendIdList.count {
                            single(.success(ref))
                            return
                        }
                    }, onError: { err in
                        single(.error(err))
                    }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    private func setRoomInfo(roomId: String, roomType: ChatRoomType, members: [String], roomTitle: String) -> Single<DatabaseReference> {
        return self.roomsRef
            .child(roomId)
            .rx
            .setValue(["members": members,
                       "title": roomTitle,
                       "host": self.myId,
                       "type": roomType.rawValue])
    }
    
    
    
    func getChatRoomIdBy(friendId: String, roomType: ChatRoomType) -> Observable<String?> {
        return Observable.create { observer in
            self.usersRef
                .child(self.myId)
                .child(roomType.rawValue)
                .rx
                .observeSingleEvent(.value)
                .subscribe(onSuccess: { snapshot in
                    guard snapshot.hasChild(friendId) else {
                        observer.onNext(nil)
                        return
                    }
                    if let retrivedChatRoomUUID = snapshot.childSnapshot(forPath: friendId).value as? String {
                        observer.onNext(retrivedChatRoomUUID)
                    }
                }, onError: { err in
                    observer.onError(err)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    /// ?????? ?????? ??? ?????? ???????????? ?????? Id?????? ?????????.
    /// - Parameter roomType: roomType
    /// - Returns: [roomId: friendId]
    func getOwnersAllChatRoomIdWithFriendId(roomType: ChatRoomType) -> Observable<[String: String]> { // [roomId: friendId]
        return Observable.create { observer in
            self.observeOwnerChatRoomSingleEvent(roomType: roomType)
                .subscribe(onSuccess: { snapshot in
                    guard snapshot.hasChildren() else {
                        observer.onNext([:])
                        return
                    }
                    let valueDict = snapshot.value as! [String: String]
                    let chatRoomIdWithFriendIdDict = valueDict.swap()
                    observer.onNext(chatRoomIdWithFriendIdDict!)
                }, onError: { err in
                    observer.onError(err)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    private func observeOwnerChatRoomSingleEvent(roomType: ChatRoomType) -> Single<DataSnapshot> {
        self.usersRef
            .child(self.myId)
            .child(roomType.rawValue)
            .rx
            .observeSingleEvent(.value)
    }
    
    
    func getChatRoomFromFirebaseBy(roomId: String) -> Observable<ChatRoom> {
        return Observable.create { observer in
            self.roomsRef
                .child(roomId)
                .rx
                .observeSingleEvent(.value)
                .subscribe { snapShot in
                    let chatRoom = self.parseDataSnapshotToChatRoom(snapShot, roomId: roomId)
                    observer.onNext(chatRoom)
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }
        }
    }
    
    
    private func parseDataSnapshotToChatRoom( _ snapShot: DataSnapshot, roomId: String) -> ChatRoom {
        let valueDict = snapShot.value as! [String: Any]
        let title = valueDict["title"] as! String
        let type = ChatRoomType(rawValue: valueDict["type"] as! String)!
        let members  = valueDict["members"] as! [String]
        let host = valueDict["host"] as! String
        return ChatRoom(UUID: roomId, title: title, chatRoomType: type, host: host, members: members, chats: [])
    }
    
    /// Owner??? ChatRoom??? ?????? ??????????????? ?????? ??? ??????.
    /// - Returns: ?????? ????????? ?????? ?????? [?????? UserId: RoomUUID]
    func listenNewRoom(roomType: ChatRoomType) -> Observable<[String: String]> {
        return Observable.create { observer in
            self.usersRef
                .child(self.myId)
                .child(roomType.rawValue)
                .rx
                .observeEvent(.childAdded)
                .subscribe(onNext: { snapShot in
                    let userId = snapShot.key
                    let roomUUID = snapShot.value as! String
                    observer.onNext([userId: roomUUID])
                    
                    switch roomType {
                    case .privateRoom:
                        self.ownerPrivateChatRoomList.append(roomUUID)
                    case .groupRoom:
                        self.ownerGroupChatRoomList.append(roomUUID)
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func preparePrivateChatRoomForTransition(friendId: String) -> Observable<ChatRoom> {
        // ?????? ???????????? ????????? ??????
        return Observable<ChatRoom>.create { [weak self] observer in
            ChatUtility.shared.getChatRoomIdBy(friendId: friendId, roomType: .privateRoom)
                .subscribe(onNext: { retrivedChatRoomUUID in
                    // ChatRoom Object ????????????
                        guard let privateChatRoomUUID = retrivedChatRoomUUID else { // ?????? ???????????? ?????? ??????
                            let roomTitle = Owner.shared.id! + friendId
                            ChatUtility.shared.createNewPrivateChatRoomOnFirebase(friendId: friendId, roomTitle: roomTitle)
                                .subscribe(onNext: { chatRoom in
                                    observer.onNext(chatRoom)
                                    observer.onCompleted()
                                }).disposed(by: (self?.disposeBag)!)
                            return
                        }
                        guard let chatRoomObject = RealmUtil.shared.readChatRoom(UUID: privateChatRoomUUID) else { // Realm??? ???????????? ???????????? Firebase?????? ????????????
                            ChatUtility.shared.getChatRoomFromFirebaseBy(roomId: privateChatRoomUUID)
                                .subscribe(onNext: { chatRoomObject in
                                    observer.onNext(chatRoomObject)
                                    observer.onCompleted()
                                }).disposed(by: (self?.disposeBag)!)
                            return
                        }
                        observer.onNext(chatRoomObject)
                        observer.onCompleted()
                }).disposed(by: (self?.disposeBag)!)
            return Disposables.create()
        }
    }
    
    func prepareGroupChatRoomForTransition(roomId: String) -> Observable<ChatRoom> {
        return Observable<ChatRoom>.create { [weak self] observer in
            guard let chatRoomObject = RealmUtil.shared.readChatRoom(UUID: roomId) else { // Realm??? ???????????? ???????????? Firebase?????? ????????????
                ChatUtility.shared.getChatRoomFromFirebaseBy(roomId: roomId)
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
    }
    
    func removeAllRoomListener() {
        for ownerPrivateChatRoom in ownerPrivateChatRoomList {
            self.roomsRef
                .child(ownerPrivateChatRoom)
                .removeAllObservers()
        }
        for ownerGroupChatRoom in ownerGroupChatRoomList {
            self.roomsRef
                .child(ownerGroupChatRoom)
                .removeAllObservers()
        }
    }
    
    
    // MARK: - Chats
    func sendMessage(roomId: String, text: String) -> Observable<Chat> {
        return Observable.create { observer in
            let timestamp =  DateFormatter().dateToDefaultFormat(date:Date())
            let newChatId = timestamp + Owner.shared.id!
            print("Log -", #fileID, #function, #line, newChatId)
            
            self.chatsRef
                .child("\(roomId)")
                .child(newChatId)
                .rx
                .updateChildValues(["from": Owner.shared.id!,
                                    "text": text,
                                    "time": timestamp])
                .subscribe { _ in
                    let chat = Chat(from: Owner.shared.id!, text: text, time: timestamp)
                    observer.onNext(chat)
                    print("Log -", #fileID, #function, #line, "success")
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func getChatsBy(roomId: String, startingId: String? = nil) -> Observable<[Chat]> {
        return Observable.create { observer in
            self.chatsRef
                .child("\(roomId)")
                .queryStarting(atValue: nil, childKey: startingId)
                .rx
                .observeSingleEvent(.value)
                .subscribe(onSuccess: { snapShot in
                    print("Log -", #fileID, #function, #line, dump(snapShot))
                    guard snapShot.exists() else {
                        print("Log -", #fileID, #function, #line, "No Chats in ChatRoom")
                        observer.onNext([])
                        return
                    }
                    let snapShotDict = snapShot.value as? [String: Any]
                    let chatDataList = Array<Any>(snapShotDict!.values)
                    
                    var chatList:Array<Chat> = []
                    for chat in chatDataList {
                        let chatDict = chat as! [String: String]
                        let from = chatDict["from"]!
                        let text = chatDict["text"]!
                        let time = chatDict["time"]!
                        let chat = Chat(from: from, text: text, time: time)
                        chatList.append(chat)
                    }
                    chatList.sort(by: {Int($0.time!)! < Int($1.time!)!})
                    observer.onNext(chatList)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    
    func listenChat(roomId: String) -> Observable<Chat?>{
        return Observable.create { observer in
            self.chatsRef
                .child(roomId)
                .queryLimited(toLast: 1)
                .rx
                .observeEvent(.value)
                .subscribe(onNext: { snapShot in
                    // ?????? ?????? ???????????? ???
                    print("Log -", #fileID, #function, #line, dump(snapShot))
                    guard snapShot.exists() else {
                        print("Log -", #fileID, #function, #line, "No Chats in ChatRoom")
                        observer.onNext(nil)
                        return
                    }
                    let snapShotDict = snapShot.value as? [String: Any]
                    let chatData = snapShotDict!.values.first as! [String: String]
                    let from = chatData["from"]!
                    let text = chatData["text"]!
                    let time = chatData["time"]!
                    let chat = Chat(from: from, text: text, time: time)
                    observer.onNext(chat)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func removeAllChatListener() {
        for ownerPrivateChatRoom in ownerPrivateChatRoomList {
            self.chatsRef
                .child(ownerPrivateChatRoom)
                .removeAllObservers()
        }
        for ownerGroupChatRoom in ownerGroupChatRoomList {
            self.chatsRef
                .child(ownerGroupChatRoom)
                .removeAllObservers()
        }
    }
}


extension DateFormatter {
    func dateToDefaultFormat(date: Date) -> String {
        self.dateFormat = "yyyyMMddHHmmssSSS"
        return self.string(from: date)
    }
}
