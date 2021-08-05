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
            let generalInfoDocRef = self.db.collection("Users").document(uid)
            // download my general info
            generalInfoDocRef.rx
                .getDocument()
                .subscribe(onNext: { doc in
                    if doc.exists {
                        let data = doc.data()
                        let email = data!["email"] as! String
                        let id = data!["id"] as! String
                        
                        self.downloadProfileImage(email)
                            .subscribe(onNext: { imgData in
                                self.downloadMyFriendList(uid)
                                    .subscribe(onNext: { friendList in
                                        print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                        print("\(friendList.count)")
                                        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                        let owner = Owner(uid: uid, email: email, id: id, profileImg: UIImage(data: imgData), friendList: friendList)
                                        observer.onNext(owner)
                                        observer.onCompleted()
                                    }).disposed(by: self.disposeBag)
                            }, onError: { err in
                                self.downloadMyFriendList(uid)
                                    .subscribe(onNext: { friendList in
                                        let owner = Owner(uid: uid, email: email, id: id, profileImg: UIImage(named: "defaultProfileImage.png"), friendList: friendList)
                                        observer.onNext(owner)
                                        observer.onCompleted()
                                    }).disposed(by: self.disposeBag)
                                
                            }).disposed(by: self.disposeBag)
                    }
                }, onError: { error in
                    observer.onNext(nil)
                    observer.onCompleted()
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func downloadMyFriendList(_ uid: String) -> Observable<[User]> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(uid).collection("Friends")
            docRef.rx
                .getDocuments()
                .subscribe(onNext: { docs in
                    var friendList: [User] = []
                    var notFoundCnt = 0
                    
                    let docObservable = Observable.from(docs.documents)
                    docObservable.subscribe(onNext: { doc in
                        let friendData = doc.data()
                        let friendEmail = doc.documentID
                        let isFriend = friendData["isFriend"] as? Bool
                        let lastUpdateRef = friendData["lastUpdateRef"] as? DocumentReference
                        
                        self.findUser(friendEmail)
                            .subscribe(onNext: { user in
                                friendList.append(user)
                                if friendList.count + notFoundCnt == docs.documents.count { observer.onNext(friendList) }
                            }, onError: { _ in
                                notFoundCnt += 1
                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                print("Could not find friend(email: \(friendEmail))")
                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                            }).disposed(by: self.disposeBag)
                    }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func findUser(_ email: String) -> Observable<User> {
        return Observable.create { observer in
            let query = self.db.collection("Users").whereField("email", isEqualTo: email)
            query.rx.getFirstDocument()
                .subscribe(onNext: { doc in
                    if doc.exists {
                        let data = doc.data()
                        let id = data["id"] as? String
                        
                        self.downloadProfileImage(email)
                            .subscribe(onNext: { data in
                                let user = User(email: email, id: id, profileImg: UIImage(data: data))
                                observer.onNext(user)
                            }, onError: { _ in
                                let user = User(email: email, id: id, profileImg: UIImage(named: "defaultProfileImage.png"))
                                observer.onNext(user)
                            }).disposed(by: self.disposeBag)
                    }
                    else {
                        observer.onError(fatalError())
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
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
                    print("profile img upload success! (email: \(email))")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(imageData)
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img upload failed (email: \(email))")
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
                    print("profile img download success! (email: \(email))")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(data)
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Error: profile img download failed (email: \(email))")
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
