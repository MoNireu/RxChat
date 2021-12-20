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
    @Persisted var id: String
    @Persisted var from: String
    @Persisted var to: String?
    @Persisted var text: String
    @Persisted var time: String?
    
    convenience init(from: String, to: String?, text: String, time: String?) {
        self.init()
        self.id = time ?? "" + from
        self.from = from
        self.to = to
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
