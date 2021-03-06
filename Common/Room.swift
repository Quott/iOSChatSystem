//
//  Room.swift
//  iOSChatSystemClient
//
//  Created by Dmitrii Titov on 09.03.2018.
//  Copyright © 2018 Dmitriy Titov. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import ObjectMapper
import SwiftyJSON

class Room: Object, Mappable {

    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var unreadMessagesCount = 0
    
    @objc dynamic var user1ID = ""
    @objc dynamic var user2ID = ""
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    init(withJSON json: JSON) {
        super.init()
        
        id = json["id"].stringValue
        name = json["name"].stringValue
        user1ID = json["user1ID"].stringValue
        user2ID = json["user2ID"].stringValue
        unreadMessagesCount = json["unreadMessagesCount"].int ?? 0
    }
    
    init(room: Room) {
        super.init()
        
        id = room.id
        name = room.name
        unreadMessagesCount = room.unreadMessagesCount
        user1ID = room.user1ID
        user2ID = room.user2ID
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        user1ID <- map["user1ID"]
        user2ID <- map["user2ID"]
        unreadMessagesCount <- map["unreadMessagesCount"]
    }
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
    
    
    func toJOSNStr() -> String {
        var jsonStr = "{"
        jsonStr.append("\"id\":\"\(id)\",")
        jsonStr.append("\"name\":\"\(name)\",")
        jsonStr.append("\"user1ID\":\"\(user1ID)\",")
        jsonStr.append("\"user2ID\":\"\(user2ID)\",")
        jsonStr.append("\"unreadMessagesCount\":\"\(unreadMessagesCount)\"")
        return jsonStr + "}"
    }
    
}
