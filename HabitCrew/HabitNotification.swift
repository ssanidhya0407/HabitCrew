//
//  HabitNotification.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 26/06/25.
//


import Foundation

struct HabitNotification {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let habitId: String
    let habitTitle: String
    let habitColorHex: String
    let isRead: Bool
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "title": title,
            "message": message,
            "timestamp": timestamp,
            "habitId": habitId,
            "habitTitle": habitTitle,
            "habitColorHex": habitColorHex,
            "isRead": isRead
        ]
    }
}