//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit

class User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
    
    let email: String
    var id: String?
    var profileImg: UIImage?
    
    init(email: String, id: String?, profileImg: UIImage?) {
        self.email = email
        self.id = id
        self.profileImg = profileImg   
    }
}
