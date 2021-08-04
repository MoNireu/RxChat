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
    
    
    init(uid: String, email: String, id: String?, profileImg: UIImage?) {
        self.uid = uid
        
        super.init(email: email, id: id, profileImg: profileImg)
    }
}
