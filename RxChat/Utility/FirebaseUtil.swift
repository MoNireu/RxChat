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
    
    
    func downloadMyData(_ uid: String) -> Observable<Owner?> {
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
                                let owner = Owner(uid: uid, email: email, id: id, profileImg: UIImage(data: imgData))
                                observer.onNext(owner)
                                observer.onCompleted()
                            }, onError: { err in
                                let owner = Owner(uid: uid, email: email, id: id, profileImg: nil)
                                observer.onNext(owner)
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
    
    
    
    func uploadMyData(_ myInfo: Owner, uploadProfileImage: Bool) -> Observable<Owner> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(myInfo.uid)
            docRef.rx
                .setData([
                    "email" : myInfo.email,
                    "id" : myInfo.id!
                ])
                .subscribe(
                    onError: { err in
                        print("Error setting user data: \(err.localizedDescription)")
                    },
                    onCompleted: {
                        guard uploadProfileImage else {return observer.onNext(myInfo)}
                        self.uploadProfileImage(myInfo.email, myInfo.profileImg!)
                            .subscribe(
                                onNext: { data in
                                    observer.onNext(myInfo)
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
    
    
    func uploadProfileUpdateTime(_ email: String) -> Observable<Void> {
        return Observable.create { observer in
            let docRef = self.db.collection("UserProfileLastUpdate").document(email)
            docRef.rx
                .setData(["lastUpdateTime" : Date()])
                .subscribe(onCompleted: {
                    observer.onCompleted()
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
