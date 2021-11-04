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
import RealmSwift
import GoogleSignIn

enum FirebaseUtilError: Error {
    case canNotFindUser
}


class FirebaseUtil {
    private let db = Firestore.firestore()
    private let STORAGE_BUCKET = "gs://rxchat-f485a.appspot.com"
    let realmUtil = RealmUtil()
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
                        
                        
                        let myLastUpdateTime = self.db.collection("UserProfileLastUpdate").document(email)
                        myLastUpdateTime.rx
                            .getDocument()
                            .subscribe(onNext: {doc in
                                var lastFriendListUpdateTime: Timestamp? = nil
                                if doc.exists {
                                    let data = doc.data()
                                    lastFriendListUpdateTime = data!["lastUpdateTime"] as! Timestamp?
                                }
                                
                                Owner.shared.uid = uid
                                Owner.shared.email = email
                                Owner.shared.id = id
                                Owner.shared.lastFriendListUpdateTime = lastFriendListUpdateTime
                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                print(Owner.shared.lastFriendListUpdateTime)
                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                
                                
                                
                                self.downloadProfileImage(email)
                                    .subscribe(onNext: { imgData in
                                        Owner.shared.profileImg = UIImage(data: imgData)
                                        
                                        self.downloadMyFriendList(uid)
                                            .subscribe(onNext: { friendList in
                                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                                print("Friend Amount: \(friendList.count)")
                                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                                
                                                // Save friend list to Realm
                                                self.realmUtil.writeFriendList(friendList: friendList)
                                                
                                                Owner.shared.friendList = friendList
                                                observer.onNext(Owner.shared)
                                                observer.onCompleted()
                                            }).disposed(by: self.disposeBag)
                                        // my profile image not found
                                    }, onError: { err in
                                        Owner.shared.profileImg = UIImage(named: "defaultProfileImage.png")
                                        
                                        self.downloadMyFriendList(uid)
                                            .subscribe(onNext: { friendList in
                                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                                print("Friend Amount: \(friendList.count)")
                                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                                
                                                // Save friend list to Realm
                                                self.realmUtil.writeFriendList(friendList: friendList)
                                                
                                                Owner.shared.friendList = friendList
                                                observer.onNext(Owner.shared)
                                                observer.onCompleted()
                                            }).disposed(by: self.disposeBag)
                                        
                                    }).disposed(by: self.disposeBag)
                            })
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
                    
                    // TODO: Get friend list from realm
                    var friendList: [User] = self.realmUtil.readFriendList()
                    var isFriendEmpty = friendList.isEmpty
                    
                    
                    // TODO: Find update required friends within friendList loop.
                    let docObservable = Observable.from(docs)
                    docObservable.subscribe(onNext: { doc in
                        let friendData = doc.data()
                        let friendEmail = doc.documentID
                        let isFriend = friendData["isFriend"] as? Bool
                        let lastUpdateRef = friendData["lastUpdateRef"] as? DocumentReference
                        
                        
                        //Download update required friends
                        self.friendUpdateRequired(userLastUpdateReference: lastUpdateRef!)
                            .subscribe(onNext: { updateRequired in
                                func checkFriendListComplete() {
                                    friendCount -= 1
                                    if friendCount == 0 {
                                        observer.onNext(friendList)
                                        observer.onCompleted()
                                    }
                                }
                                
                                var needUpdate = updateRequired
                                if isFriendEmpty { needUpdate = true }
                                
                                if needUpdate {
                                    self.findUser(friendEmail)
                                        .subscribe(onNext: { user in
                                            if let index = friendList.firstIndex(of: user) {
                                                friendList[index] = user
                                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                                print("friend already exist in realm")
                                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                            }
                                            else {
                                                friendList.append(user)
                                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                                print("friend does not exist in realm")
                                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                                            }
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
            
            let imageData = image.jpegData(compressionQuality: 0.5)!
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
                    print(err.localizedDescription)
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
            // Upload on UserProfileLastUpdate Collection
            let profileLastUpdateDocRef = self.db.collection("UserProfileLastUpdate").document(email)
            profileLastUpdateDocRef.rx
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
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("Update Required?: True")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
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
                            print("Update Required?: True")
                            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                            
                            observer.onNext(true)
                        default:
                            print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                            print("Update Required?: False")
                            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                            
                            observer.onNext(false)
                        }
                    }
                    else {
                        print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                        print("Update Required?: False")
                        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                        
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
    
    
    func ownerSignIn(authentication: GIDAuthentication) -> Observable<Void> {
        return Observable.create { observer in
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                guard error == nil else {
                    print("Error: Firebase Sign-in Failed")
                    print(error?.localizedDescription)
                    return
                }
                
                print("Firebase Sign-in Suceed!")
                
                let uid = authResult!.user.uid
                let email = authResult!.user.email
                
                Owner.shared.uid = uid
                
                // TODO: 유저 초기 저장하고 Edit완료시 Update 시간 Realm에 저장하기.
                if RealmUtil().ownerRealmExist() {
                    print("Owner Realm exist")
                    Owner.shared.lastFriendListUpdateTime = RealmUtil().readOwner().lastFriendListUpdateTime
                    print("Owner lastFriendListUpdateTime = \(Owner.shared.lastFriendListUpdateTime)")
                }
                else {
                    print("Owner Realm does not exist")
                }
                
                
                print("UID: " + uid)
                print("Email: " + email!)
                
                
                self.downloadMyData(uid)
                    .subscribe(onNext: { user in
                        if user != nil {
                            Owner.shared.email = user!.email
                            Owner.shared.id = user!.id
                            Owner.shared.profileImg = user!.profileImg
                            Owner.shared.friendList = user!.friendList
                            print("User exist")
                        }
                        else {
                            Owner.shared.uid = uid
                            Owner.shared.email = email!
                            Owner.shared.id = nil
                            Owner.shared.profileImg = nil
                            Owner.shared.friendList = []
                            print("User not exist")
                        }
                        
                        observer.onCompleted()
                    }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
}
