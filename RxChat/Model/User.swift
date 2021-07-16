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
    var id: String?
    var profileImgData: Data?
    
    
    init(email: String, id: String?, profileImgData: Data?) {
        self.email = email
        self.id = id
        self.profileImgData = profileImgData
    }
}
