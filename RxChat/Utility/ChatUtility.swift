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
                .subscribe { snapShot in
                    observer.onNext(Chat(from: Owner.shared.id!, to: nil, text: text, time: timestamp))
                    print("Log -", #fileID, #function, #line, "succ")
                } onError: { err in
                    print("Log -", #fileID, #function, #line, err.localizedDescription)
                }
            return Disposables.create()
        }
    }
    
    
    func listenPrivateChatRoom(UUID: String) {
        ref.child("privateChat/\(UUID)")
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
