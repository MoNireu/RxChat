//
//  Chat.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/10.
//

import Foundation
import RxDataSources
import RealmSwift

class Chat: EmbeddedObject {
    @Persisted var from: String
    @Persisted var text: String
    @Persisted var time: String?
    
    convenience init(from: String, text: String, time: String?) {
        self.init()
        self.from = from
        self.text = text
        self.time = time
    }
}

struct SectionOfChatData {
    var header: String
    var items: [Item]
}

extension SectionOfChatData: SectionModelType {
  typealias Item = Chat

   init(original: SectionOfChatData, items: [Item]) {
    self = original
    self.items = items
  }
}

