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


class ChatUtility {
    static let shared = ChatUtility()
    var disposeBag = DisposeBag()
    
    
//    private let ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    private let _ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/")
    private lazy var usersRef = _ref.reference(withPath: "users")
    private lazy var roomsRef = _ref.reference(withPath: "rooms")
    private lazy var chatsRef = _ref.reference(withPath: "chats")
    let myId = Owner.shared.id!
    
    
    // MARK: - ChatRoom
    var ownerPrivateChatRoomList: [String] = [] // [PrivateRoomUUID]
    var ownerGroupChatRoomList: [String] = [] // [GroupRoomUUID]
    
    func createPrivateChatRoom(friendId: String, roomTitle: String, roomType: ChatRoomType) -> Observable<ChatRoom> {
        return Observable.create { observer in
            let roomId = UUID().uuidString
            let setFriendRoomIdOnOwner = self.usersRef
                .child(self.myId)
                .child("private")
                .rx
                .updateChildValues([friendId: roomId])
            
            let setOwnerRoomIdOnFriend = self.usersRef
                .child(friendId)
                .child("private")
                .rx
                .updateChildValues([self.myId: roomId])
            
            Observable.of(setFriendRoomIdOnOwner, setOwnerRoomIdOnFriend)
                .merge()
                .subscribe(onCompleted: {
                    let setMembers =
                    self.roomsRef
                        .child(roomId)
                        .child("members")
                        .rx
                        .setValue([self.myId, friendId])
                    
                    let setTitle =
                    self.roomsRef
                        .child(roomId)
                        .child("title")
                        .rx
                        .setValue(roomTitle)
                    
                    let setRoomType =
                    self.roomsRef
                        .child(roomId)
                        .child("type")
                        .rx
                        .setValue(roomType.rawValue)
                    
                    Observable.of(setMembers, setTitle, setRoomType)
                        .merge()
                        .subscribe(onError: { err in
                            print("Log -", #fileID, #function, #line, "Error")
                        }, onCompleted: {
                            print("Log -", #fileID, #function, #line, "Success")
                            let chatRoom = ChatRoom(UUID: roomId, title: roomTitle, chatRoomType: roomType, members: [self.myId, friendId], chats: [])
                            observer.onNext(chatRoom)
                        }).disposed(by: self.disposeBag)
                    
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
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
    
    
    /// 나의 친구 및 단체 채팅방의 모든 Id들을 가져옴.
    /// - Parameter roomType: roomType
    /// - Returns: [roomId: friendId]
    func getOwnersAllChatRoomIdWithFriendId(roomType: ChatRoomType) -> Observable<[String: String]> { // [roomId: friendId]
        return Observable.create { observer in
            self.usersRef
                .child(self.myId)
                .child(roomType.rawValue)
                .rx
                .observeSingleEvent(.value)
                .subscribe(onSuccess: { snapshot in
                    guard snapshot.hasChildren() else {
                        observer.onNext([:])
                        return
                    }
                    let valueDict = snapshot.value as! [String: String]
                    var chatRoomIdWithFriendIdDict: [String: String] = [:]
                    for (key, value) in valueDict {
                        chatRoomIdWithFriendIdDict.updateValue(key, forKey: value)
                    }
                    observer.onNext(chatRoomIdWithFriendIdDict)
                }, onError: { err in
                    observer.onError(err)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    
    
    func getChatRoomBy(roomId: String) -> Observable<ChatRoom> {
        return Observable.create { observer in
            self.roomsRef
                .child(roomId)
                .rx
                .observeSingleEvent(.value)
                .subscribe { snapShot in
                    let valueDict = snapShot.value as! [String: Any]
                    let title = valueDict["title"] as! String
                    let type = ChatRoomType(rawValue: valueDict["type"] as! String)!
                    let members  = valueDict["members"] as! [String]
                    let chatRoom = ChatRoom(UUID: roomId, title: title, chatRoomType: type, members: members, chats: [])
                    observer.onNext(chatRoom)
                    
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }

        }
    }
    
    /// Owner의 ChatRoom이 새로 생성되는지 확인 후 반환.
    /// - Returns: 새로 생성된 방의 정보 [상대 UserId: RoomUUID]
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
                    // 방을 처음 만들었을 떄
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
    
    
    //MARK: - Private Functions
    
    
    /// Find chat room by UUID and returns chat room members
    /// - Parameters:
    ///   - UUID: UUID of chat room
    ///   - chatRoomType: Type of chat room
    /// - Returns: List of chat room memeber's Id
//    private func getChatRoomMembers(UUID: String, chatRoomType: ChatRoomType) -> Single<[String]> {
//        return Single.create { observer in
//            self.ref.child("\(chatRoomType.rawValue)/\(UUID)/members")
//                .observeSingleEvent(of: .value) { snapshot in
//                    let members = snapshot.value as! Dictionary<String, Any>
//                    let membersOrderedList = Array(members.keys).sorted()
//                    observer(.success(membersOrderedList))
//                }
//            return Disposables.create()
//        }
//    }
    
//    private func getChatContexts(UUID: String, chatRoomType: ChatRoomType) -> Single<[Chat]> {
//        return Single.create { observer in
//            self.ref.child("\(chatRoomType.rawValue)/\(UUID)/chat")
//                .observeSingleEvent(of: .value) { snapshot in
//                    if snapshot.exists() {
//                        // TODO: Chat Object를 만들어서 반환
//                    }
//                    else {
//                        observer(.success([]))
//                    }
//                }
//
//            return Disposables.create()
//        }
//    }
}


extension DateFormatter {
    func dateToDefaultFormat(date: Date) -> String {
        self.dateFormat = "yyyyMMddHHmmssSSS"
        return self.string(from: date)
    }
}
