//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit

class Owner: User {
    var uid: String
    var friendList: [User]
    
    
    init(uid: String, email: String, id: String?, profileImg: UIImage?, friendList: [User]) {
        self.uid = uid
        self.friendList = friendList
        
        super.init(email: email, id: id, profileImg: profileImg)
    }
}
