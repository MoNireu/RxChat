//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit
import Firebase
import RealmSwift

class Owner: User {
    var uid: String
    var friendList: [String: User]
    var lastFriendListUpdateTime: Timestamp?
    static let shared = Owner(uid: "", id: "", email: "", name: "", lastFriendListUpdateTime: nil, profileImg: nil, friendList: [:])
    
    private init(uid: String, id: String?, email: String, name: String?, lastFriendListUpdateTime: Timestamp?, profileImg: UIImage?, friendList: [String: User]) {
        self.uid = uid
        self.friendList = friendList
        self.lastFriendListUpdateTime = lastFriendListUpdateTime
        
        super.init(id: id, email: email, name: name, profileImg: profileImg)
    }
    
    class func sharedInit(uid: String, id: String?, email: String, name: String?, lastFriendListUpdateTime: Timestamp?, profileImg: UIImage?, friendList: [String: User]) {
        self.shared.uid = uid
        self.shared.id = id
        self.shared.email = email
        self.shared.name = name
        self.shared.lastFriendListUpdateTime = lastFriendListUpdateTime
        self.shared.profileImg = profileImg
        self.shared.friendList = friendList
    }
}


class OwnerRealm: Object {
    @Persisted(primaryKey: true) var uid: String
    @Persisted var lastFriendListUpdateTime: Date?
    
    convenience init(owner: Owner) {
        self.init()
        self.uid = owner.uid
        self.lastFriendListUpdateTime = (owner.lastFriendListUpdateTime?.dateValue())
    }
}
