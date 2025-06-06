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

extension Habit {
    // Check if habit should be completed today based on frequency
    func shouldCompleteToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) // 1 = Sunday, 2 = Monday, etc.
        
        switch frequency {
        case .daily:
            // Daily habits should be completed every day
            return true
            
        case .weekly:
            // Weekly habits - check if today is the same day of week as when the habit was created
            let startWeekday = calendar.component(.weekday, from: startDate)
            return today == startWeekday
            
        case .monthly:
            // Monthly habits - check if today is the same day of month as when the habit was created
            let startDay = calendar.component(.day, from: startDate)
            let currentDay = calendar.component(.day, from: Date())
            return currentDay == startDay
            
        case .custom:
            // For custom frequency, since we don't have customDays property,
            // We'll assume custom means specific days were selected elsewhere
            // For now, default to returning true (needs completion today)
            return true
            
        default:
            // Default behavior for any other frequencies
            return true
        }
    }
}


import Foundation

extension Habit {
    /// Number of completions for the current period (today, this week, this month, or custom logic).
    var progress: Int {
        switch frequency {
        case .daily:
            // 1 if completed today, 0 otherwise
            return isCompletedToday() ? 1 : 0
        case .weekly:
            // Count completions in this week (Monday-Sunday)
            let calendar = Calendar.current
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
            return completedDates.filter { weekInterval.contains($0) }.count
        case .monthly:
            // Count completions this month
            let calendar = Calendar.current
            guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return 0 }
            return completedDates.filter { monthInterval.contains($0) }.count
        case .custom:
            // For now, treat as daily (custom logic can go here)
            return isCompletedToday() ? 1 : 0
        }
    }

    /// The required completions for the current period (daily=1, weekly=1, monthly=1, custom=1 by default).
    var total: Int {
        switch frequency {
        case .daily: return 1
        case .weekly: return 1 // If you want to require eg. 3 times a week, change this logic.
        case .monthly: return 1
        case .custom: return 1 // Or customize per your app logic
        }
    }
}
