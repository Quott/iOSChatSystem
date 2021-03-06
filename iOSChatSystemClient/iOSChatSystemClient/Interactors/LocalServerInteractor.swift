//
//  LocalServerInteractor.swift
//  iOSChatSystemClient
//
//  Created by Dmitrii Titov on 03.03.2018.
//  Copyright © 2018 Dmitriy Titov. All rights reserved.
//

import UIKit
import SwiftyJSON

class LocalServerInteractor: NSObject {
    
    static let shared: LocalServerInteractor = {
        let instance = LocalServerInteractor()
        return instance
    }()
    
    func execute(method: String, params: JSON, completion: ((String) -> ())) {
        if !method.contains("ping") {
            print("")
        }
        execute(method: ClientsMethod(rawValue: method) ?? ClientsMethod.Unknown, params: params, completion: completion)
    }
    
    private func execute(method: ClientsMethod, params: JSON, completion: ((String) -> ())) {
        let text = { () -> String in
            switch method {
            case .Unknown:
                return ""
            case .ReceiveMessage:
                return receiveMessage(params: params["params"])
            case .ReceiveChatMessage:
                return receiveChatMessage(params: params)
            case .Ping:
                return "{\"message\":\"pong\"}"
            }
        }()
        
        completion(text)
    }
    
    func receiveChatMessage(params: JSON) -> String {
        let request_uuid = params["answer_request_uuid"].stringValue
        let method = params["params"]["method"].stringValue
        switch ClientsMethod.Room(rawValue: method) ?? ClientsMethod.Room.Unknown {
        case .GetMessages:
            return getMessages(params: params)
        case .ReceiveMessage:
            return receiveRoomMessage(params: params)
        case .Ping:
            return ""
        case .Unknown:
            return ""
        case .ReceiveMessages:
            return receiveMessages(params: params)
        }
        return ""
    }
    
    func receiveMessages(params: JSON) -> String {
        let messages = params["params"]["messages"].arrayValue
        for rawMessage in messages {
            let message = Message(withJSON: rawMessage)
            RoomsManager.shared.receiveMessage(message: message)
        }
        return ""
    }
    
    func receiveMessage(params: JSON) -> String {
        let request_uuid = params["answer_request_uuid"].stringValue
        SocketManager.shared.complete(withRequestUUID: request_uuid, params: params)
        return ""
    }
    
    func getMessages(params: JSON) -> String {
        print("getMessages")
        
        let request_uuid = params["params"]["request_uuid"].stringValue
        let roomID = params["params"]["roomID"].stringValue
        let senderURLString = params["params"]["senderURLString"].stringValue
        guard let manager = RoomsManager.shared.manager(forID: roomID) else {
            return ""
        }
        let messages = manager.loadLocalMessages()
        var messagesJSONSTring = "["
        for (index, message) in messages.enumerated() {
            let jsonString = message.toJSONStr() + ((index == messages.count - 1) ? "]" : ",")
            messagesJSONSTring.append(jsonString)
        }
        if messagesJSONSTring == "[" {
            messagesJSONSTring = "[]"
        }
        ChatSocketManager.sharedCSM.write(urlString: senderURLString,
                                          params: [
                                            "method": ClientsMethod.Room.ReceiveMessages.rawValue,
                                            "answer_request_uuid": request_uuid,
                                            "messages": messagesJSONSTring
            ],
                                          completion: nil)
        
        return ""
    }
    
    func receiveRoomMessage(params: JSON) -> String {
        let message = Message(withJSON: params["params"])
        RoomsManager.shared.receiveMessage(message: message)
        return ""
    }
    
    func receiveRooms(params: JSON) -> String {
        
        let rooms = params["rooms"].arrayValue
        
        return ""
    }

}
