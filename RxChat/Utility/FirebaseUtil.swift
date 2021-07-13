//
//  FirebaseControl.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import RxFirebase
import Firebase
import RxSwift


class FirebaseUtil {
    let db = Firestore.firestore()
    let disposeBag = DisposeBag()
    
    func retriveUserData(_ uid: String) -> Observable<User?> {
        return Observable.create { observer in
            self.db.collection("Users").document(uid).rx
                .getDocument()
                .subscribe(onNext: { doc in
                    if doc.exists {
                        let data = doc.data()
                        let email = data!["email"] as! String
                        let id = data!["id"] as! String
                        
                        observer.onNext(User(email: email, id: id))
                    }
                    observer.onCompleted()
                }, onError: { error in
                    observer.onNext(nil)
                    observer.onCompleted()
                })
        }
    }
    
    
    
    func setUserData(_ uid: String, _ email: String, _ id: String) {
        let docRef = db.collection("Users").document(uid)
        docRef.rx
            .setData([
                "email" : email,
                "id" : id
            ])
            .subscribe(onError: { err in
                print("Error setting user data: \(err.localizedDescription)")
            })
            .dispose()
    }
}
