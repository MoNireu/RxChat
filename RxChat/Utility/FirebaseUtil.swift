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
    
    
    func downloadMyData(_ uid: String) -> Observable<User?> {
        return Observable.create { observer in
            self.db.collection("Users").document(uid).rx
                .getDocument()
                .subscribe(onNext: { doc in
                    if doc.exists {
                        let data = doc.data()
                        let email = data!["email"] as! String
                        let id = data!["id"] as! String
                        
                        self.downloadProfileImage(email)
                            .subscribe(onNext: { imgData in
                                let user = User(email: email, uid: uid, id: id, profileImg: UIImage(data: imgData))
                                observer.onNext(user)
                                observer.onCompleted()
                            }, onError: { err in
                                let user = User(email: email, uid: uid, id: id, profileImg: nil)
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
    
    
    
    func uploadMyData(_ userInfo: User, uploadProfileImage: Bool) -> Observable<User> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(userInfo.uid!)
            docRef.rx
                .setData([
                    "email" : userInfo.email,
                    "id" : userInfo.id!
                ])
                .subscribe(
                    onError: { err in
                        print("Error setting user data: \(err.localizedDescription)")
                    },
                    onCompleted: {
                        guard uploadProfileImage else {return observer.onNext(userInfo)}
                        self.uploadProfileImage(userInfo.email, userInfo.profileImg!)
                            .subscribe(
                                onNext: { data in
                                    observer.onNext(userInfo)
                                }
                            ).disposed(by: self.disposeBag)
                    }
                ).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func uploadProfileImage(_ email: String, _ image: UIImage) -> Observable<Data> {
        return Observable.create { observer in
            let ref = Storage.storage()
                .reference(forURL: "\(self.STORAGE_BUCKET)/images/profile/\(email).jpg")
                .rx
            
            let imageData = image.jpegData(compressionQuality: 0.8)!
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
    
    
    func downloadProfileImage(_ email: String) -> Observable<Data> {
        return Observable.create { observer in
            let ref = Storage.storage()
                .reference(forURL: "\(self.STORAGE_BUCKET)/images/profile/\(email).jpg")
                .rx
            
            ref.getData(maxSize: 1 * 1024 * 1024)
                .subscribe(onNext: { data in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img download success!")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(data)
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Error: profile img download failed")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onError(err)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
