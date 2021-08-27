//
//  SectionOfUserList.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/27.
//

import Foundation
import RxDataSources

struct SectionOfUserData {
  var header: String
  var items: [Item]
}
extension SectionOfUserData: SectionModelType {
  typealias Item = User

   init(original: SectionOfUserData, items: [Item]) {
    self = original
    self.items = items
  }
}
