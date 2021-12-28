//
//  ChatRoom.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/10.
//

enum ChatRoomType: String {
    case privateRoom = "private"
    case groupRoom = "group"
}


import Foundation
import RealmSwift
import RxDataSources


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
    
    init(chatRoomRealm: ChatRoomRealm) {
        self.UUID = chatRoomRealm.UUID
        self.title = chatRoomRealm.title
        self.chatRoomType = ChatRoomType(rawValue: chatRoomRealm.chatRoomType)!
        self.members = Array(chatRoomRealm.members)
        self.chats = Array(chatRoomRealm.chats)
    }
}


// MARK: - Realm
class ChatRoomRealm: Object {
    @Persisted var UUID: String
    @Persisted var title: String
    @Persisted var chatRoomType: String
    @Persisted var members: List<String>
    @Persisted var chats: List<Chat>
    
    override static func primaryKey() -> String? {
        return "UUID"
    }
    
    convenience init(chatRoom: ChatRoom) {
        self.init()
        self.UUID = chatRoom.UUID
        self.title = chatRoom.title
        self.chatRoomType = chatRoom.chatRoomType.rawValue
        self.members = List<String>()
        self.members.append(objectsIn: chatRoom.members)
        self.chats = List<Chat>()
        self.chats.append(objectsIn: chatRoom.chats)
    }
}


// MARK: - RxDatasources
struct SectionOfChatRoomData {
    var header: String
    var items: [Item]
}

extension SectionOfChatRoomData: SectionModelType {
  typealias Item = ChatRoom

   init(original: SectionOfChatRoomData, items: [Item]) {
    self = original
    self.items = items
  }
}
