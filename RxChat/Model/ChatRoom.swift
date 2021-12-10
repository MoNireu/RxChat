//
//  ChatRoom.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/10.
//

enum ChatRoomType: String {
    case privateRoom = "privateChat"
    case groupRoom = "groupChat"
}


import Foundation


class ChatRoom {
    var UUID: String
    var title: String
    var chatRoomType: ChatRoomType
    var members: [String]
    var chats: [Chat]
    
    init(UUID: String,title: String, chatRoomType: ChatRoomType, members: [String], chats: [Chat]) {
        self.UUID = UUID
        self.title = title
        self.chatRoomType = chatRoomType
        self.members = members
        self.chats = chats
    }
}
