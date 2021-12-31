//
//  User.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/12.
//

import Foundation
import UIKit
import RealmSwift
import RxDataSources
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
    var name: String?
    var profileImg: UIImage?
    
    init(id: String?, email: String, name: String?, profileImg: UIImage?) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImg = profileImg
    }
}


// MARK: - Realm
class UserRealm: Object {
    @Persisted var id: String?
    @Persisted var email: String?
    @Persisted var name: String?
    @Persisted var profileImg: Data?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - RxTableViewSectionedReloadDataSource
struct SectionOfUserData {
  var items: [Item]
}

extension SectionOfUserData: SectionModelType {
  typealias Item = User

   init(original: SectionOfUserData, items: [Item]) {
    self = original
    self.items = items
  }
}


// MARK: - RxTableViewSectionedAnimatedDataSource
struct SectionOfAnimatableUserData: AnimatableSectionModelType {
    var uniqueId: String
    var header: String
    var items: [Item]
    
    typealias Identity = String
    var identity: String {
        return uniqueId
    }
}


extension SectionOfAnimatableUserData: SectionModelType {
    typealias Item = User
    
    init(original: SectionOfAnimatableUserData, items: [Item]) {
        self = original
        self.items = items
    }
}
