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
    private var ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    let myId = Owner.shared.id!
    
    func createPrivateChatRoom(friendId: String) -> Observable<String> {
        return Observable.create { observer in
            let chatUUID = UUID().uuidString
            // 내 개인채팅 목록에 상대 추가
            self.ref.child("users")
                .child(self.myId)
                .child("privateChat")
                .rx
                .updateChildValues([friendId: chatUUID])
                .subscribe(onSuccess: { _ in
                    // 상대 개인채팅 목록에 나를 추가
                    self.ref.child("users")
                        .child(friendId)
                        .child("privateChat")
                        .rx
                        .updateChildValues([self.myId: chatUUID])
                        .subscribe(onSuccess: {  _ in
                            // 채팅방 만들고 해당 인원 추가.
                            self.ref.child("privateChat")
                                .child(chatUUID)
                                .child("members")
                                .rx
                                .setValue([self.myId: true,
                                          friendId: true])
                                .subscribe(onSuccess: { _ in
                                    print("Success")
                                    observer.onNext(chatUUID)
                                }, onError: { err in
                                    print("Error creatingPrivateChatRoom")
                                }).disposed(by: self.disposeBag)
                        }, onError: { err in
                            
                        }).disposed(by: self.disposeBag)
                }, onError: { err in
                    
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    func getPrivateChatRoomUUID(friendId: String) -> Observable<String?> {
        return Observable.create { observer in
            self.ref.child("users")
                .child(self.myId)
                .child("privateChat")
                .rx
                .observeSingleEvent(.value)
                .subscribe(onSuccess: { snapshot in
                    if snapshot.hasChild(friendId) {
                        if let retrivedChatRoomUUID = snapshot.childSnapshot(forPath: friendId).value as? String {
                            observer.onNext(retrivedChatRoomUUID)
                        }
                    }
                    else {
                        observer.onNext(nil)
                    }
                }, onError: { err in
                    observer.onError(err)
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    func createChatRoomObjectBy(UUID: String, chatRoomType: ChatRoomType) -> Observable<ChatRoom> {
        return Observable.create { observer in
            self.getChatRoomMembers(UUID: UUID, chatRoomType: chatRoomType)
                .subscribe(onSuccess: { members in
                    let membersToString: String = members.joined(separator: ", ")
                    self.getChatContexts(UUID: UUID, chatRoomType: chatRoomType)
                        .subscribe(onSuccess: { chats in
                            let chatRoom = ChatRoom(UUID: UUID, title: membersToString, chatRoomType: chatRoomType, members: members, chats: chats)
                            observer.onNext(chatRoom)
                        }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func sendMessage(UUID: String, text: String) -> Observable<Chat> {
        return Observable.create { observer in
            let timestamp =  DateFormatter().dateToDefaultFormat(date:Date())
            let newChatId = timestamp + Owner.shared.id!
            print("Log -", #fileID, #function, #line, newChatId)
            
            self.ref.child("privateChat/\(UUID)")
                .child("chats")
                .child(newChatId)
                .rx
                .updateChildValues(["from": Owner.shared.id!,
                                    "text": text,
                                    "time": timestamp])
                .subscribe { _ in
                    let chat = Chat(from: Owner.shared.id!, text: text, time: timestamp)
                    self.setLastMessage(UUID: UUID, chat: chat)
                    observer.onNext(chat)
                    print("Log -", #fileID, #function, #line, "succ")
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func setLastMessage(UUID: String, chat: Chat) {
        self.ref.child("privateLastMessage/\(UUID)")
            .rx
            .updateChildValues(["from": Owner.shared.id!,
                                "text": chat.text,
                                "time": chat.time])
            .subscribe { _ in } onError: { _ in }
            .disposed(by: self.disposeBag)

    }
    
    func getPrivateChatFrom(UUID: String, fromId: String? = nil) -> Observable<[Chat]> {
        return Observable.create { observer in
            self.ref.child("privateChat/\(UUID)/chats")
                .queryStarting(atValue: nil, childKey: fromId)
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
    func listenOwnerPrivateRoom() -> Observable<[String: String]> {
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
    
    
    
    func listenPrivateChatRoom(UUID: String) -> Observable<Chat?> {
        return Observable.create { observer in
            self.ref.child("privateChat/\(UUID)/chats")
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
    
    func removeListenerFromPrivateChatRoom(UUID: String) {
        self.ref.child("privateChat/\(UUID)/chats")
            .removeAllObservers()
    }
    
    
    //MARK: - Private Functions
    
    
    /// Find chat room by UUID and returns chat room members
    /// - Parameters:
    ///   - UUID: UUID of chat room
    ///   - chatRoomType: Type of chat room
    /// - Returns: List of chat room memeber's Id
    private func getChatRoomMembers(UUID: String, chatRoomType: ChatRoomType) -> Single<[String]> {
        return Single.create { observer in
            self.ref.child("\(chatRoomType.rawValue)/\(UUID)/members")
                .observeSingleEvent(of: .value) { snapshot in
                    let members = snapshot.value as! Dictionary<String, Any>
                    let membersOrderedList = Array(members.keys).sorted()
                    observer(.success(membersOrderedList))
                }
            return Disposables.create()
        }
    }
    
    private func getChatContexts(UUID: String, chatRoomType: ChatRoomType) -> Single<[Chat]> {
        return Single.create { observer in
            self.ref.child("\(chatRoomType.rawValue)/\(UUID)/chat")
                .observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        // TODO: Chat Object를 만들어서 반환
                    }
                    else {
                        observer(.success([]))
                    }
                }
            
            return Disposables.create()
        }
    }
}


extension DateFormatter {
    func dateToDefaultFormat(date: Date) -> String {
        self.dateFormat = "yyyyMMddHHmmssSSS"
        return self.string(from: date)
    }
}
