//
//  HabitCrewModels.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 13/06/25.
//

import Foundation

// --- Your existing UserProfile and Group ---
struct UserProfile {
    let uid: String
    let displayName: String
    let isOnline: Bool?        // Optional, not always present
    let lastSeen: Date?        // Optional

    var dictionary: [String: Any] {
        [
            "uid": uid,
            "displayName": displayName,
            "isOnline": isOnline as Any,
            "lastSeen": lastSeen?.timeIntervalSince1970 as Any
        ]
    }
    init(uid: String, displayName: String, isOnline: Bool? = nil, lastSeen: Date? = nil) {
        self.uid = uid
        self.displayName = displayName
        self.isOnline = isOnline
        self.lastSeen = lastSeen
    }
    init?(from dict: [String: Any]) {
        guard let uid = dict["uid"] as? String else { return nil }
        let displayName = dict["displayName"] as? String ?? dict["name"] as? String
        self.uid = uid
        self.displayName = displayName ?? "Unknown"
        self.isOnline = dict["isOnline"] as? Bool
        if let lastSeen = dict["lastSeen"] as? Double {
            self.lastSeen = Date(timeIntervalSince1970: lastSeen)
        } else {
            self.lastSeen = nil
        }
    }
}

struct Group: Identifiable {
    let id: String
    let name: String
    let description: String
    let imageURL: String?
    let memberUIDs: [String]
    var dictionary: [String: Any] {
        [
            "id": id,
            "name": name,
            "description": description,
            "imageURL": imageURL as Any,
            "memberUIDs": memberUIDs
        ]
    }
}
// --- New Models for Messaging/Features ---

// For group habit-based threads
struct HabitThread: Identifiable {
    let id: String                  // Firestore doc id
    let habitName: String
    let createdBy: String           // user id
}

// For all messages (DM, group, habit thread)
enum MessageType: String {
    case text
    case checkin
    case nudge
    case summary
    case voice
    case motivation
    case poll
    case image      // <-- Add this line
    case system
}

struct HabitMessage: Identifiable {
    let id: String
    let senderId: String
    let timestamp: Date
    let type: MessageType
    let content: String?
    let audioURL: String?
    let checkinData: CheckinData?
    let summaryData: SummaryData?
    let pollData: PollData?
    let reactions: [String: [String]]?

    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "senderId": senderId,
            "timestamp": timestamp.timeIntervalSince1970,
            "type": type.rawValue,
            "content": content as Any,
            "audioURL": audioURL as Any
        ]
        if let checkinData = checkinData { dict["checkinData"] = checkinData.dictionary }
        if let summaryData = summaryData { dict["summaryData"] = summaryData.dictionary }
        if let pollData = pollData { dict["pollData"] = pollData.dictionary }
        if let reactions = reactions { dict["reactions"] = reactions }
        return dict
    }

    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let senderId = dict["senderId"] as? String,
              let timestamp = dict["timestamp"] as? Double,
              let typeStr = dict["type"] as? String,
              let type = MessageType(rawValue: typeStr)
        else { return nil }
        self.id = id
        self.senderId = senderId
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.type = type
        self.content = dict["content"] as? String
        self.audioURL = dict["audioURL"] as? String
        self.checkinData = (dict["checkinData"] as? [String: Any]).flatMap { CheckinData(from: $0) }
        self.summaryData = (dict["summaryData"] as? [String: Any]).flatMap { SummaryData(from: $0) }
        self.pollData = (dict["pollData"] as? [String: Any]).flatMap { PollData(from: $0) }
        self.reactions = dict["reactions"] as? [String: [String]]
    }

    // ADD THIS MEMBERWISE INITIALIZER
    init(
        id: String,
        senderId: String,
        timestamp: Date,
        type: MessageType,
        content: String?,
        audioURL: String?,
        checkinData: CheckinData?,
        summaryData: SummaryData?,
        pollData: PollData?,
        reactions: [String: [String]]?
    ) {
        self.id = id
        self.senderId = senderId
        self.timestamp = timestamp
        self.type = type
        self.content = content
        self.audioURL = audioURL
        self.checkinData = checkinData
        self.summaryData = summaryData
        self.pollData = pollData
        self.reactions = reactions
    }
}

// Check-in data (for checkin messages)
struct CheckinData {
    let habitName: String
    let date: Date
    let status: String // "completed", "skipped", etc.
    let note: String?
    var dictionary: [String: Any] {
        [
            "habitName": habitName,
            "date": date.timeIntervalSince1970,
            "status": status,
            "note": note as Any
        ]
    }
    init(habitName: String, date: Date, status: String, note: String?) {
        self.habitName = habitName
        self.date = date
        self.status = status
        self.note = note
    }
    init?(from dict: [String: Any]) {
        guard let habitName = dict["habitName"] as? String,
              let date = dict["date"] as? Double,
              let status = dict["status"] as? String
        else { return nil }
        self.habitName = habitName
        self.date = Date(timeIntervalSince1970: date)
        self.status = status
        self.note = dict["note"] as? String
    }
}

// Summary card data
struct SummaryData {
    let period: String // "weekly", etc.
    let participants: [SummaryParticipant]
    let groupName: String?
    var dictionary: [String: Any] {
        [
            "period": period,
            "participants": participants.map { $0.dictionary },
            "groupName": groupName as Any
        ]
    }
    init(period: String, participants: [SummaryParticipant], groupName: String?) {
        self.period = period
        self.participants = participants
        self.groupName = groupName
    }
    init?(from dict: [String: Any]) {
        guard let period = dict["period"] as? String,
              let participantsArr = dict["participants"] as? [[String: Any]]
        else { return nil }
        self.period = period
        self.groupName = dict["groupName"] as? String
        self.participants = participantsArr.compactMap { SummaryParticipant(from: $0) }
    }
}

struct SummaryParticipant {
    let uid: String
    let name: String
    let checkins: Int
    let streak: Int
    let superlatives: [String]?
    var dictionary: [String: Any] {
        [
            "uid": uid,
            "name": name,
            "checkins": checkins,
            "streak": streak,
            "superlatives": superlatives as Any
        ]
    }
    init(uid: String, name: String, checkins: Int, streak: Int, superlatives: [String]?) {
        self.uid = uid
        self.name = name
        self.checkins = checkins
        self.streak = streak
        self.superlatives = superlatives
    }
    init?(from dict: [String: Any]) {
        guard let uid = dict["uid"] as? String,
              let name = dict["name"] as? String,
              let checkins = dict["checkins"] as? Int,
              let streak = dict["streak"] as? Int
        else { return nil }
        self.uid = uid
        self.name = name
        self.checkins = checkins
        self.streak = streak
        self.superlatives = dict["superlatives"] as? [String]
    }
}

// Poll data
struct PollData {
    let question: String
    let options: [String]
    let votes: [String: String] // userId: option
    let isActive: Bool
    var dictionary: [String: Any] {
        [
            "question": question,
            "options": options,
            "votes": votes,
            "isActive": isActive
        ]
    }
    init(question: String, options: [String], votes: [String: String], isActive: Bool) {
        self.question = question
        self.options = options
        self.votes = votes
        self.isActive = isActive
    }
    init?(from dict: [String: Any]) {
        guard let question = dict["question"] as? String,
              let options = dict["options"] as? [String],
              let votes = dict["votes"] as? [String: String],
              let isActive = dict["isActive"] as? Bool
        else { return nil }
        self.question = question
        self.options = options
        self.votes = votes
        self.isActive = isActive
    }
}

// Nudge model (for nudge messages)
struct Nudge {
    let senderId: String
    let recipientId: String
    let timestamp: Date
    let message: String?
    var dictionary: [String: Any] {
        [
            "senderId": senderId,
            "recipientId": recipientId,
            "timestamp": timestamp.timeIntervalSince1970,
            "message": message as Any
        ]
    }
    init(senderId: String, recipientId: String, timestamp: Date, message: String?) {
        self.senderId = senderId
        self.recipientId = recipientId
        self.timestamp = timestamp
        self.message = message
    }
    init?(from dict: [String: Any]) {
        guard let senderId = dict["senderId"] as? String,
              let recipientId = dict["recipientId"] as? String,
              let timestamp = dict["timestamp"] as? Double
        else { return nil }
        self.senderId = senderId
        self.recipientId = recipientId
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.message = dict["message"] as? String
    }
}
