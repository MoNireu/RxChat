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
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()
    private let STORAGE_BUCKET = "gs://rxchat-f485a.appspot.com"
    
    
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
    
    
    func uploadProfileImage(_ email: String, _ profileImage: UIImage) {
        let ref = Storage.storage()
            .reference(forURL: "\(STORAGE_BUCKET)/images/profile/\(email).jpg")
            .rx
        
        var imageData = Data()
        imageData = profileImage.jpegData(compressionQuality: 0.8)!
        ref.putData(imageData)
            .subscribe(onNext: { metaData in
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("profile img upload success!")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")

            }, onError: { err in
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("profile img upload failed")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
            }).disposed(by: disposeBag)
    }
    
    
    func downloadProfileImage(_ email: String) -> Observable<UIImage> {
        var img = UIImage()
        let ref = Storage.storage()
            .reference(forURL: "\(STORAGE_BUCKET)/images/profile/\(email).jpg")
            .rx
        
        ref.getData(maxSize: 1 * 1024 * 1024)
            .subscribe(onNext: { data in
                img = UIImage()
                if let _img = UIImage(data: data) {
                    img = _img
                }
            }, onError: { err in
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("profile img download failed")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
            })
        return Observable.just(img)
    }
}
