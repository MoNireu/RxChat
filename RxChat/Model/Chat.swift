//
//  Chat.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/10.
//

import Foundation
import RxDataSources

class Chat {
    var from: String
    var to: String?
    var text: String
    var time: String?
    
    init(from: String, to: String?, text: String, time: String?) {
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
