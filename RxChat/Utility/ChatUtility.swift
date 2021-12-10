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


class ChatUtility {
    
    var disposeBag = DisposeBag()
    private var ref = Database.database(url: "https://rxchat-f485a-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    
    func createPrivateChatRoom(friendId: String) -> Observable<Void> {
        return Observable.create { observer in
            let chatUUID = UUID().uuidString
            
            let myId = Owner.shared.id!
            
            // 내 개인채팅 목록에 상대 추가
            self.ref.child("users")
                .child(myId)
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
                        .updateChildValues([myId: chatUUID])
                        .subscribe(onSuccess: {  _ in
                            print("2")
                            // 채팅방 만들고 해당 인원 추가.
                            self.ref.child("privateChat")
                                .child(chatUUID)
                                .child("member")
                                .rx
                                .setValue([myId: true,
                                          friendId: true])
                                .subscribe(onSuccess: { _ in
                                    print("Success")
                                    observer.onNext(())
                                }, onError: { err in
                                    
                                }).disposed(by: self.disposeBag)
                        }, onError: { err in
                            
                        }).disposed(by: self.disposeBag)
                }, onError: { err in
                    
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }

}
