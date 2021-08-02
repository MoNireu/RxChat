//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit

class User {
    let email: String
    var uid: String?
    var id: String?
    var profileImg: UIImage?
    
    
    init(email: String, uid: String?, id: String?, profileImg: UIImage?) {
        self.email = email
        self.uid = uid
        self.id = id
        self.profileImg = profileImg
    }
}
