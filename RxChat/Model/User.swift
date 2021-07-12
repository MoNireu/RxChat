//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation

struct User {
    let email: String
    var id: String?
    
    init(email: String, id: String?) {
        self.email = email
        self.id = id
    }
}
