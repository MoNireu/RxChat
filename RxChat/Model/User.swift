//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit
import RealmSwift
import Differentiator


class User: Equatable, IdentifiableType {
    typealias Identity = String
    var identity: String {
        return id ?? ""
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var email: String
    var profileImg: UIImage?
    
    init(id: String?, email: String, profileImg: UIImage?) {
        self.id = id
        self.email = email
        self.profileImg = profileImg
    }
}


class UserRealm: Object {
    @Persisted var email: String?
    @Persisted var id: String?
    @Persisted var profileImg: Data?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
