//
//  SectionOfUserList.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/27.
//

import Foundation
import RxDataSources

struct SectionOfUserData: AnimatableSectionModelType {
    var uniqueId: String
    var header: String
    var items: [Item]
    
    typealias Identity = String
    var identity: String {
        return uniqueId
    }
}


extension SectionOfUserData: SectionModelType {
    typealias Item = User
    
    init(original: SectionOfUserData, items: [Item]) {
        self = original
        self.items = items
    }
}
