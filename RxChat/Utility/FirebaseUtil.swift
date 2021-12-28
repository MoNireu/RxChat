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
    private var disposeBag = DisposeBag()
    
    
    //MARK: - Download
    // Download my base info from firebase
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
                        let name = data!["name"] as! String
                        
                        
                        let myLastUpdateTime = self.db.collection("UserProfileLastUpdate").document(id)
                        let myLastUpdateTimeObservable = myLastUpdateTime.rx.getDocument()
                        
                        Observable
                            .zip(myLastUpdateTimeObservable,
                                 self.downloadProfileImage(id),
                                 self.downloadMyFriendList(uid))
                        { lastUpdateTimeDoc, profileImageData, friendList in
                            let lastFriendListUpdateTime: Timestamp? = {
                                guard doc.exists else { return nil }
                                let data = doc.data()
                                return data!["lastUpdateTime"] as! Timestamp?
                            }()
                            
                            Owner.shared.uid = uid
                            Owner.shared.email = email
                            Owner.shared.id = id
                            Owner.shared.name = name
                            Owner.shared.lastFriendListUpdateTime = lastFriendListUpdateTime
                            Owner.shared.friendList = friendList
                            Owner.shared.profileImg = {
                                guard let profileImageData = profileImageData else {
                                    return UIImage(named: "defaultProfileImage.png")
                                }
                                return UIImage(data: profileImageData)
                            }()
                            
                            RealmUtil.shared.writeFriendList(friendList: Array<User>(friendList.values))
                            
                        }
                        .subscribe { _ in
                            observer.onNext(Owner.shared)
                            observer.onCompleted()
                        } onError: { err in
                            print("Log -", #fileID, #function, #line, err.localizedDescription)
                            observer.onError(err)
                        }.disposed(by: self.disposeBag)


                        
                        
                        
//                        myLastUpdateTime.rx
//                            .getDocument()
//                            .subscribe(onNext: { doc in
//                                var lastFriendListUpdateTime: Timestamp? = nil
//                                if doc.exists {
//                                    let data = doc.data()
//                                    lastFriendListUpdateTime = data!["lastUpdateTime"] as! Timestamp?
//                                }
//
//                                Owner.shared.uid = uid
//                                Owner.shared.email = email
//                                Owner.shared.id = id
//                                Owner.shared.name = name
//                                Owner.shared.lastFriendListUpdateTime = lastFriendListUpdateTime
//
//                                self.downloadProfileImage(id)
//                                    .subscribe(onNext: { imgData in
//                                        Owner.shared.profileImg = UIImage(data: imgData)
//
//                                        self.downloadMyFriendList(uid)
//                                            .subscribe(onNext: { friendList in
//                                                // Save friend list to Realm
//                                                RealmUtil.shared.writeFriendList(friendList: Array<User>(friendList.values))
//
//                                                Owner.shared.friendList = friendList
//                                                observer.onNext(Owner.shared)
//                                                observer.onCompleted()
//                                            }).disposed(by: self.disposeBag)
//                                        // my profile image not found
//                                    }, onError: { err in
//                                        Owner.shared.profileImg = UIImage(named: "defaultProfileImage.png")
//
//                                        self.downloadMyFriendList(uid)
//                                            .subscribe(onNext: { friendList in
//                                                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
//                                                print("Friend Amount: \(friendList.count)")
//                                                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
//
//                                                // Save friend list to Realm
//                                                RealmUtil.shared.writeFriendList(friendList: Array<User>(friendList.values))
//
//                                                Owner.shared.friendList = friendList
//                                                observer.onNext(Owner.shared)
//                                                observer.onCompleted()
//                                            }).disposed(by: self.disposeBag)
//
//                                    }).disposed(by: self.disposeBag)
//                            }).disposed(by: self.disposeBag)
                    }
                }, onError: { error in
                    observer.onNext(nil)
                    observer.onCompleted()
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    func downloadMyFriendList(_ uid: String) -> Observable<[String: User]> {
        return Observable.create { observer in
            let colRef = self.db.collection("Users").document(uid).collection("Friends")
            colRef.rx
                .getDocuments()
                .subscribe(onNext: { data in
                    let docs = data.documents
                    guard !docs.isEmpty else {
                        observer.onNext([:])
                        return
                    }
                    var friendCount = docs.count
                    
                    // Get friend list from realm
                    var friendList: [String: User] = {
                        var dict: [String: User] = [:]
                        for user in RealmUtil.shared.readFriendList() {
                            dict.updateValue(user, forKey: user.id!)
                        }
                        return dict
                    }()
                    var isFriendEmpty = friendList.isEmpty
                    
                    
                    // Find update required friends within friendList loop.
                    let docObservable = Observable.from(docs)
                    docObservable.subscribe(onNext: { doc in
                        let friendData = doc.data()
                        let friendID = doc.documentID
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
                                    self.findUser(friendID)
                                        .subscribe(onNext: { user in
                                            if friendList.keys.contains(user.id!) {
                                                friendList[user.id!] = user
                                                print("Log -", #fileID, #function, #line, "friend already exist in realm")
                                            }
                                            else {
                                                friendList.updateValue(user, forKey: user.id!)
                                                print("Log -", #fileID, #function, #line, "friend does not exist in realm")
                                            }
                                            checkFriendListComplete()
                                        }, onError: { _ in
                                            print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                                            print("Could not find friend(ID: \(friendID))")
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
    
    
    func downloadProfileImage(_ id: String) -> Observable<Data?> {
        return Observable.create { observer in
            let ref = Storage.storage()
                .reference(forURL: "\(self.STORAGE_BUCKET)/images/profile/\(id).jpg")
                .rx
            
            ref.getData(maxSize: 1 * 1024 * 1024)
                .subscribe(onNext: { data in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img download success! (id: \(id))")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(data)
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Error: profile img download failed (id: \(id))")
                    print(err.localizedDescription)
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(nil)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    func findUser(_ id: String) -> Observable<User> {
        return Observable.create { observer in
            let query = self.db.collection("Users").whereField("id", isEqualTo: id)
            query.rx.getDocuments()
                .subscribe(onNext: { doc in
                    if doc.count != 0 {
                        let data = doc.documents.first!.data()
                        let email = data["email"] as? String
                        let name = data["name"] as? String
                        
                        self.downloadProfileImage(id)
                            .subscribe(onNext: { data in
                                let user = User(id: id,
                                                email: email!,
                                                name: name!,
                                                profileImg: data != nil ? UIImage(data: data!) : UIImage(named: "defaultProfileImage.png"))
                                observer.onNext(user)
                            }, onError: { err in
                                observer.onError(err)
                            }).disposed(by: self.disposeBag)
                    }
                    else {
                        observer.onError(FirebaseUtilError.canNotFindUser)
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    
    // MARK: - Upload
    func uploadMyData(_ myInfo: Owner, isProfileImageChanged: Bool) -> Observable<Owner> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(myInfo.uid)
            docRef.rx
                .setData([
                    "id" : myInfo.id,
                    "email" : myInfo.email,
                ])
                .subscribe(
                    onError: { err in
                        print("Error setting user data: \(err.localizedDescription)")
                    },
                    onCompleted: {
                        guard isProfileImageChanged else {return observer.onNext(myInfo)}
                        self.uploadProfileImage(myInfo.id!, myInfo.profileImg!)
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
    
    
    func uploadProfileImage(_ id: String, _ image: UIImage) -> Observable<Data> {
        return Observable.create { observer in
            let ref = Storage.storage()
                .reference(forURL: "\(self.STORAGE_BUCKET)/images/profile/\(id).jpg")
                .rx
            
            let imageData = image.jpegData(compressionQuality: 0.5)!
            ref.putData(imageData)
                .subscribe(onNext: { metaData in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img upload success! (email: \(id))")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onNext(imageData)
                    observer.onCompleted()
                }, onError: { err in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("profile img upload failed (email: \(id))")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                    observer.onError(err)
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    
    func uploadProfileUpdateTime(_ id: String) -> Observable<Void> {
        return Observable.create { observer in
            print("Log -", #fileID, #function, #line, id)
            // Upload on UserProfileLastUpdate Collection
            let profileLastUpdateDocRef = self.db.collection("UserProfileLastUpdate").document(id)
            profileLastUpdateDocRef.rx
                .setData(["lastUpdateTime" : Timestamp(date: Date())])
                .subscribe(onCompleted: {
                    observer.onCompleted()
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    // MARK: - ETC
    func addFriend(ownerUID: String, newFriend: User) -> Observable<User> {
        return Observable.create { observer in
            let docRef = self.db.collection("Users").document(ownerUID).collection("Friends").document(newFriend.id!)
            docRef.rx
                .setData([
                    "isFriend": true,
                    "lastUpdateRef": self.db.document("/UserProfileLastUpdate/" + newFriend.id!)
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
    
    
    /// SignIn Google and Firebase by GIDAuthentication. Then Returns if user is new or not.
    /// - Parameter authentication: GIDAuthentication
    /// - Returns: True: User is new to this service / False: User already exist
    func ownerSignIn(authentication: GIDAuthentication) -> Observable<Bool> {
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
                if RealmUtil.shared.ownerRealmExist() {
                    print("Owner Realm exist")
                    Owner.shared.lastFriendListUpdateTime = RealmUtil.shared.readOwner().lastFriendListUpdateTime
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
                            observer.onNext(false)
                            print("User exist")
                        }
                        else {
                            Owner.shared.uid = uid
                            Owner.shared.email = email!
                            Owner.shared.id = nil
                            Owner.shared.profileImg = nil
                            Owner.shared.friendList = [:]
                            observer.onNext(true)
                            print("User not exist")
                        }
                    }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
}
