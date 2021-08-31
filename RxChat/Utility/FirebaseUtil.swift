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

enum FirebaseUtilError: Error {
    case canNotFindUser
}


class FirebaseUtil {
    private let db = Firestore.firestore()
    private let STORAGE_BUCKET = "gs://rxchat-f485a.appspot.com"
    
    private let disposeBag = DisposeBag()
    
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
                        let lastFriendListUpdateTime = data!["lastFriendListUpdateTime"] as! Timestamp?
                        
                        Owner.shared.uid = uid
                        Owner.shared.email = email
                        Owner.shared.id = id
                        Owner.shared.lastFriendListUpdateTime = lastFriendListUpdateTime
                        
                        
                        
                        self.downloadProfileImage(email)
                            .subscribe(onNext: { imgData in
                                Owner.shared.profileImg = UIImage(data: imgData)
                                
                                self.downloadMyFriendList(uid)
                                    .subscribe(onNext: { friendList in
                                        print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                        print("Friend Amount: \(friendList.count)")
                                        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                        
                                        Owner.shared.friendList = friendList
                                        observer.onNext(Owner.shared)
                                        observer.onCompleted()
                                    }).disposed(by: self.disposeBag)
                            // my profile image not found
                            }, onError: { err in
                                Owner.shared.profileImg = UIImage(named: "defaultProfileImage.png")
                                
                                self.downloadMyFriendList(uid)
                                    .subscribe(onNext: { friendList in
                                        Owner.shared.friendList = friendList
                                        observer.onNext(Owner.shared)
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
            let colRef = self.db.collection("Users").document(uid).collection("Friends")
            colRef.rx
                .getDocuments()
                .subscribe(onNext: { data in
                    let docs = data.documents
                    guard !docs.isEmpty else {
                        observer.onNext([])
                        return
                    }
                    var friendCount = docs.count
                    var friendList: [User] = []
                    
                    let docObservable = Observable.from(docs)
                    docObservable.subscribe(onNext: { doc in
                        let friendData = doc.data()
                        let friendEmail = doc.documentID
                        let isFriend = friendData["isFriend"] as? Bool
                        let lastUpdateRef = friendData["lastUpdateRef"] as? DocumentReference
                        
                        
                        //Download update required friends
                        self.friendUpdateRequired(userLastUpdateReference: lastUpdateRef!)
                            .subscribe(onNext: { needUpdate in
                                func checkFriendListComplete() {
                                    friendCount -= 1
                                    if friendCount == 0 {
                                        observer.onNext(friendList)
                                        observer.onCompleted()
                                    }
                                }
                                
                                if needUpdate {
                                    self.findUser(friendEmail)
                                        .subscribe(onNext: { user in
                                            friendList.append(user)
                                            checkFriendListComplete()
                                        }, onError: { _ in
                                            print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                            print("Could not find friend(email: \(friendEmail))")
                                            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                            checkFriendListComplete()
                                        }).disposed(by: self.disposeBag)
                                }
                                else {
                                    checkFriendListComplete()
                                }
                            }).disposed(by: self.disposeBag)
                    }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func findUser(_ email: String) -> Observable<User> {
        return Observable.create { observer in
            let query = self.db.collection("Users").whereField("email", isEqualTo: email)
            query.rx.getDocuments()
                .subscribe(onNext: { doc in
                    if doc.count != 0 {
                        let data = doc.documents.first!.data()
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
                        observer.onError(FirebaseUtilError.canNotFindUser)
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    
    func uploadMyData(_ myInfo: Owner, isProfileImageChanged: Bool) -> Observable<Owner> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(myInfo.uid)
            docRef.rx
                .setData([
                    "email" : myInfo.email,
                    "id" : myInfo.id!,
                ])
                .subscribe(
                    onError: { err in
                        print("Error setting user data: \(err.localizedDescription)")
                    },
                    onCompleted: {
                        guard isProfileImageChanged else {return observer.onNext(myInfo)}
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
                .setData(["lastUpdateTime" : Timestamp(date: Date())])
                .subscribe(onCompleted: {
                    observer.onCompleted()
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    func addFriend(ownerUID: String, newFriend: User) -> Observable<User> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(ownerUID).collection("Friends").document(newFriend.email)
            docRef.rx
                .setData([
                    "isFriend": true,
                    "lastUpdateRef": self.db.document("/UserProfileLastUpdate/" + newFriend.email)
                ])
                .subscribe(onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Error: Problem adding friend to firestore")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                }, onCompleted: {
                    observer.onCompleted()
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Add friend to firestore complete")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                }).disposed(by: self.disposeBag)
            //
            return Disposables.create()
        }
    }
    
    func friendUpdateRequired(userLastUpdateReference: DocumentReference) -> Observable<Bool> {
        return Observable.create { observer in
            guard let lastFriendListUpdateTime = Owner.shared.lastFriendListUpdateTime else {
                observer.onNext(true)
                return Disposables.create()
            }
        
            userLastUpdateReference.rx.getDocument()
                .subscribe(onNext: { info in
                    if let data = info.data() {
                        let lastUpdateTime = data["lastUpdateTime"] as! Timestamp
                        let compare = lastUpdateTime.compare(lastFriendListUpdateTime)
                        switch compare {
                        case .orderedDescending:
                            print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                            print("True")
                            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                            
                            observer.onNext(true)
                        default:
                            print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                            print("False")
                            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                            
                            observer.onNext(false)
                        }
                    }
                    else {
                        observer.onNext(false)
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    
    func updateFriendListRefreshTime() -> Observable<Void> {
        return Observable.create { observer in
            let docRef = self.db.document("/Users/\(Owner.shared.uid)")
            docRef.rx
                .setData(["lastFriendListUpdateTime" : Timestamp.init(date: Date())])
                .subscribe(onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Error: LastFriendListUpdateTime error!")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                }, onCompleted: {
                    observer.onCompleted()
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
}
