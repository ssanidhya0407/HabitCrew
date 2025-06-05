//
//  Habit.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import Foundation
import FirebaseFirestore

enum HabitFrequency: String, Codable {
    case daily, weekly, monthly, custom
}

struct Habit: Codable {
    let id: String
    var title: String
    var description: String?
    var ownerId: String
    var buddyIds: [String]?
    var frequency: HabitFrequency
    var color: String // Store as hex code
    var icon: String // Store as SF Symbol name
    var startDate: Date
    var completedDates: [Date]
    var streak: Int
    
    // Firestore serialization
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description ?? "",
            "ownerId": ownerId,
            "buddyIds": buddyIds ?? [],
            "frequency": frequency.rawValue,
            "color": color,
            "icon": icon,
            "startDate": Timestamp(date: startDate),
            "completedDates": completedDates.map { Timestamp(date: $0) },
            "streak": streak
        ]
    }
    
    static func fromFirestore(data: [String: Any]) -> Habit? {
        guard
            let id = data["id"] as? String,
            let title = data["title"] as? String,
            let ownerId = data["ownerId"] as? String,
            let frequencyString = data["frequency"] as? String,
            let frequency = HabitFrequency(rawValue: frequencyString),
            let color = data["color"] as? String,
            let icon = data["icon"] as? String,
            let startDateTimestamp = data["startDate"] as? Timestamp,
            let completedDatesTimestamps = data["completedDates"] as? [Timestamp],
            let streak = data["streak"] as? Int
        else { return nil }
        
        let description = data["description"] as? String
        let buddyIds = data["buddyIds"] as? [String]
        
        return Habit(
            id: id,
            title: title,
            description: description,
            ownerId: ownerId,
            buddyIds: buddyIds,
            frequency: frequency,
            color: color,
            icon: icon,
            startDate: startDateTimestamp.dateValue(),
            completedDates: completedDatesTimestamps.map { $0.dateValue() },
            streak: streak
        )
    }
    
    // Check if habit is completed for today
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completedDates.contains { date in
            calendar.isDate(date, inSameDayAs: Date())
        }
    }
}
