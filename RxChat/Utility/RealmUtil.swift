//
//  RealmUtil.swift
//  RxChat
//
//  Created by MoNireu on 2021/10/05.
//

import Foundation
import RealmSwift

class RealmUtil {
    
    let realm = try! Realm()
    
    // Test
    init() {
        print("Realm is located at:", realm.configuration.fileURL!)
    }
    
    private func convertUserClassToUserRealm(user: User) -> UserRealm {
        let userRealm = UserRealm()
        userRealm.email = user.email
        userRealm.id = user.id
        userRealm.profileImg = user.profileImg?.jpegData(compressionQuality: 0.5)
        
        return userRealm
    }
    
    
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
    
    
}
