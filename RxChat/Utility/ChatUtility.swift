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
    
    
    private let ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    private let _ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/")
    private lazy var usersRef = _ref.reference(withPath: "users")
    private lazy var roomsRef = _ref.reference(withPath: "rooms")
    private lazy var chatsRef = _ref.reference(withPath: "chats")
    let myId = Owner.shared.id!
    
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
    
    
    func getChatRoomIdBy(friendId: String) -> Observable<String?> {
        return Observable.create { observer in
            self.usersRef
                .child(self.myId)
                .child("private")
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
    
    
//    func createChatRoomObjectBy(UUID: String, chatRoomType: ChatRoomType) -> Observable<ChatRoom> {
//        return Observable.create { observer in
//            self.getChatRoomMembers(UUID: UUID, chatRoomType: chatRoomType)
//                .subscribe(onSuccess: { members in
//                    let membersToString: String = members.joined(separator: ", ")
//                    self.getChatContexts(UUID: UUID, chatRoomType: chatRoomType)
//                        .subscribe(onSuccess: { chats in
//                            let chatRoom = ChatRoom(UUID: UUID, title: membersToString, chatRoomType: chatRoomType, members: members, chats: chats)
//                            observer.onNext(chatRoom)
//                        }).disposed(by: self.disposeBag)
//                }).disposed(by: self.disposeBag)
//            return Disposables.create()
//        }
//    }
    
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
//                    self.setLastMessage(UUID: roomId, chat: chat)
                    observer.onNext(chat)
                    print("Log -", #fileID, #function, #line, "success")
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
//    func setLastMessage(UUID: String, chat: Chat) {
//        self.ref.child("privateLastMessage/\(UUID)")
//            .rx
//            .updateChildValues(["from": Owner.shared.id!,
//                                "text": chat.text,
//                                "time": chat.time])
//            .subscribe { _ in } onError: { _ in }
//            .disposed(by: self.disposeBag)
//
//    }
    
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
    
    
    func getPrivateChatRoomUUIDDict() -> Observable<[String: String]> {
        return Observable.create { observer in
            self.ref.child("users/\(Owner.shared.id!)/privateChat")
                .rx
                .observeSingleEvent(.value)
                .subscribe { snapShot in
                    guard let chatRoomDict = snapShot.value as? [String: String] else {
                        observer.onNext([:])
                        return
                    }
                    observer.onNext(chatRoomDict)
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    /// Owner의 PrivateRoom이 새로 생성되는지 확인 후 반환.
    /// - Returns: 새로 생성된 방의 정보 [상대 UserId: RoomUUID]
    func listenOwnerChatRoom() -> Observable<[String: String]> {
        return Observable.create { observer in
            self.ref.child("users/\(Owner.shared.id!)/privateChat")
                .rx
                .observeEvent(.childAdded)
                .subscribe(onNext: { snapShot in
                    observer.onNext([snapShot.key: snapShot.value as! String])
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func listenPrivateLastMessage(UUIDList: [String]) -> Observable<[String: Chat]?> {
        return Observable.create { observer in
            for roomUUID in UUIDList {
                self.ref.child("privateLastMessage")
                    .queryEqual(toValue: nil, childKey: roomUUID)
                    .rx
                    .observeEvent(.value)
                    .subscribe(onNext: { snapShot in
                        guard snapShot.exists() else {
                            observer.onNext(nil)
                            return
                        }
                        let roomDict = snapShot.value as! [String: [String: String]]
                        let chatDict = roomDict[roomUUID]!
                        observer.onNext([roomUUID: Chat(from: chatDict["from"]!, text: chatDict["text"]!, time: chatDict["time"])])
                    }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    
    
    func listenChatRoom(roomId: String) -> Observable<Chat?> {
        return Observable.create { observer in
            self.chatsRef
                .child("\(roomId)")
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
    
    func removeListenerFromPrivateChatRoom(roomId: String) {
        self.chatsRef
            .child("\(roomId)")
            .removeAllObservers()
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
