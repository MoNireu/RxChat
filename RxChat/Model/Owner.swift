//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit
import Firebase

class Owner: User {
    var uid: String
    var friendList: [User]
    var lastFriendListUpdateTime: Timestamp?
    static let shared = Owner(uid: "", email: "", id: "", lastFriendListUpdateTime: nil, profileImg: nil, friendList: [])
    
    private init(uid: String, email: String, id: String?, lastFriendListUpdateTime: Timestamp?, profileImg: UIImage?, friendList: [User]) {
        self.uid = uid
        self.friendList = friendList
        self.lastFriendListUpdateTime = lastFriendListUpdateTime
        
        super.init(email: email, id: id, profileImg: profileImg)
    }
    
    class func sharedInit(uid: String, email: String, id: String?, lastFriendListUpdateTime: Timestamp?, profileImg: UIImage?, friendList: [User]) {
        self.shared.uid = uid
        self.shared.email = email
        self.shared.id = id
        self.shared.lastFriendListUpdateTime = lastFriendListUpdateTime
        self.shared.profileImg = profileImg
        self.shared.friendList = friendList
    }
}
