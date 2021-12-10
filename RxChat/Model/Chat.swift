//
//  Chat.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/10.
//

import Foundation

class Chat {
    var from: String
    var to: String
    var text: String
    var time: Date
    
    init(from: String, to: String, text: String, time: Date) {
        self.from = from
        self.to = to
        self.text = text
        self.time = time
    }
}
