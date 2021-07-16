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
                        
                        self.downloadProfileImage(email)
                            .subscribe(onNext: { img in
                                let user = User(email: email, id: id, profileImg: img)
                                observer.onNext(user)
                                observer.onCompleted()
                            })
                            .disposed(by: self.disposeBag)
                    }
                }, onError: { error in
                    observer.onNext(nil)
                    observer.onCompleted()
                })
        }
    }
    
    
    
    func uploadUserData(_ uid: String, _ email: String, _ id: String) {
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
    
    
    func uploadProfileImage(_ email: String, _ profileImage: UIImage) -> Observable<Data> {
        return Observable.create { observer in
            let ref = Storage.storage()
                .reference(forURL: "\(self.STORAGE_BUCKET)/images/profile/\(email).jpg")
                .rx
            
            var imageData = Data()
            imageData = profileImage.jpegData(compressionQuality: 0.8)!
            ref.putData(imageData)
                .subscribe(onNext: { metaData in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img upload success!")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(imageData)
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img upload failed")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onError(err)
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    func downloadProfileImage(_ email: String) -> Observable<UIImage> {
        return Observable.create { observer in
            let ref = Storage.storage()
                .reference(forURL: "\(self.STORAGE_BUCKET)/images/profile/\(email).jpg")
                .rx
            
            ref.getData(maxSize: 1 * 1024 * 1024)
                .subscribe(onNext: { data in
                    if let image = UIImage(data: data) {
                        print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                        print("profile img download success!")
                        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                        observer.onNext(image)
                    }
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Error: profile img download failed")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    let defaultImg = UIImage(named: "defaultProfileImage.png")
                    observer.onNext(defaultImg!)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
