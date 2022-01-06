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
    var host: String
    var members: [String]
    var chats: [Chat]
    
    init(UUID: String,title: String, chatRoomType: ChatRoomType, host: String, members: [String], chats: [Chat]) {
        self.UUID = UUID
        self.title = title
        self.chatRoomType = chatRoomType
        self.host = host
        self.members = members
        self.chats = chats
    }
    
    init(chatRoomRealm: ChatRoomRealm) {
        self.UUID = chatRoomRealm.UUID
        self.title = chatRoomRealm.title
        self.chatRoomType = ChatRoomType(rawValue: chatRoomRealm.chatRoomType)!
        self.host = chatRoomRealm.host
        self.members = Array(chatRoomRealm.members)
        self.chats = Array(chatRoomRealm.chats)
    }
    
    
    func getFriendIdFromChatRoom() -> String {
        let firstId = self.members.first!
        let secondId = self.members.last!
        return firstId != Owner.shared.id! ? firstId : secondId
    }
}


// MARK: - Realm
class ChatRoomRealm: Object {
    @Persisted var UUID: String
    @Persisted var title: String
    @Persisted var chatRoomType: String
    @Persisted var host: String
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
        self.host = chatRoom.host
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
