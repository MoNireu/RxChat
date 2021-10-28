//
//  RealmUtil.swift
//  RxChat
//
//  Created by MoNireu on 2021/10/05.
//

import Foundation
import RealmSwift
import Firebase

class RealmUtil {
    
    let realm = try! Realm()
    
    // Test
    init() {
        print("Realm is located at:", realm.configuration.fileURL!)
    }
    
    
    // MARK: - Class Convert Functions
    private func convertUserClassToUserRealm(user: User) -> UserRealm {
        let userRealm = UserRealm()
        userRealm.email = user.email
        userRealm.id = user.id
        userRealm.profileImg = user.profileImg?.jpegData(compressionQuality: 0.5)
        
        return userRealm
    }
    
    
    // MARK: - Friend CRUD
    func readFriendList() -> [User] {
        let friendListRealm = realm.objects(UserRealm.self)
        var friendList: [User] = []
        
        for friendRealm in friendListRealm {
            friendList.append(User(email: friendRealm.email!, id: friendRealm.id, profileImg: UIImage(data: friendRealm.profileImg!)))
        }
        
        return friendList
    }
    
    
    func writeFriendList(friendList: [User]) {
        try! realm.write {
            var friendListRealm: [UserRealm] = []
            for friend in friendList {
                let userRealm = convertUserClassToUserRealm(user: friend)
                friendListRealm.append(userRealm)
            }
            realm.add(friendListRealm, update: .modified)
        }
    }
    
    
    func writeSingleFriend(friendInfo: User) {
        try! realm.write {
            let userRealm = convertUserClassToUserRealm(user: friendInfo)
            realm.add(userRealm, update: .modified)
        }
    }
    
    
    
    // MARK: - Owner CRUD
    
    func ownerRealmExist() -> Bool {
        if realm.objects(OwnerRealm.self).count == 0 { return false }
        else { return true }
    }
    
    
    func writeOwner(owner: Owner) {
        try! realm.write {
            let ownerRealm = OwnerRealm(owner: owner)
            realm.add(ownerRealm, update: .modified)
        }
    }
    
    
    func readOwner() -> Owner {
        let OwnerRealm = realm.objects(OwnerRealm.self).first
        if let lastUpdateTime = OwnerRealm?.lastFriendListUpdateTime {
            Owner.shared.lastFriendListUpdateTime = Timestamp.init(date: lastUpdateTime)
        }
        return Owner.shared
    }
    
}
