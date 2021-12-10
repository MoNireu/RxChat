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
                    print("1")
                    // 상대 개인채팅 목록에 나를 추가
                    self.ref.child("users")
                        .child(friendId)
                        .child("privateChat")
                        .rx
                        .updateChildValues([self.myId: chatUUID])
                        .subscribe(onSuccess: {  _ in
                            print("2")
                            // 채팅방 만들고 해당 인원 추가.
                            self.ref.child("privateChat")
                                .child(chatUUID)
                                .child("member")
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
    
    
    func checkPrivateChatRoomExist(friendId: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.ref.child("users")
                .child(self.myId)
                .child("privateChat")
                .queryEqual(toValue: friendId)
                .rx
                .observeSingleEvent(.value)
                .subscribe(onSuccess: { _ in
                    observer.onNext(true)
                }, onError: { err in
                    observer.onNext(false)
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
//    func connectToChatRoom(_ UUID: String) {
//
//    }
}
