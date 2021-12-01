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
    
    
    func createPrivateChatRoom(friendEmail: String) -> Observable<Void> {
        return Observable.create { observer in
            let chatUUID = UUID().uuidString
            
            let myModifiedEmail = Owner.shared.email.removeDotFromEmail()
            let friendModifiedEmail = friendEmail.removeDotFromEmail()
            
            // 내 개인채팅 목록에 상대 추가
            self.ref.child("users")
                .child(myModifiedEmail)
                .child("privateChat")
                .rx
                .updateChildValues([friendModifiedEmail: chatUUID])
                .subscribe(onSuccess: { _ in
                    print("1")
                    // 상대 개인채팅 목록에 나를 추가
                    self.ref.child("users")
                        .child(friendModifiedEmail)
                        .child("privateChat")
                        .rx
                        .updateChildValues([myModifiedEmail: chatUUID])
                        .subscribe(onSuccess: {  _ in
                            print("2")
                            // 채팅방 만들고 해당 인원 추가.
                            self.ref.child("privateChat")
                                .child(chatUUID)
                                .child("member")
                                .rx
                                .setValue([myModifiedEmail: true,
                                          friendModifiedEmail: true])
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
