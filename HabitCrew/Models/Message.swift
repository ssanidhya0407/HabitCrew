//
//  Message.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import Foundation
import FirebaseFirestore

enum MessageType: String, Codable {
    case text, voiceNote, quote, emoji
}

struct Message: Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let type: MessageType
    let content: String
    let timestamp: Date
    let isRead: Bool
    
    // Firestore serialization
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "senderId": senderId,
            "receiverId": receiverId,
            "type": type.rawValue,
            "content": content,
            "timestamp": Timestamp(date: timestamp),
            "isRead": isRead
        ]
    }
    
    static func fromFirestore(data: [String: Any]) -> Message? {
        guard
            let id = data["id"] as? String,
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let typeString = data["type"] as? String,
            let type = MessageType(rawValue: typeString),
            let content = data["content"] as? String,
            let timestampData = data["timestamp"] as? Timestamp,
            let isRead = data["isRead"] as? Bool
        else { return nil }
        
        return Message(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            type: type,
            content: content,
            timestamp: timestampData.dateValue(),
            isRead: isRead
        )
    }
}
