import Foundation
import FirebaseFirestore

struct Habit: Codable {
    var id: String
    var title: String
    var note: String?
    var createdAt: Date
    var friend: String
    var schedule: Date
    var icon: String
    var colorHex: String
    var days: [Int]         // [0-6] for Sun-Sat
    var motivation: String?
    var remindIfMiss: Bool
    var doneDates: [String: Bool] // e.g., ["2025-06-13": true]

    var dictionary: [String: Any] {
        [
            "id": id,
            "title": title,
            "note": note ?? "",
            "createdAt": Timestamp(date: createdAt),
            "friend": friend,
            "schedule": Timestamp(date: schedule),
            "icon": icon,
            "colorHex": colorHex,
            "days": days,
            "motivation": motivation ?? "",
            "remindIfMiss": remindIfMiss,
            "doneDates": doneDates
        ]
    }

    init(id: String = UUID().uuidString, title: String, note: String?, createdAt: Date = Date(), friend: String, schedule: Date, icon: String, colorHex: String, days: [Int], motivation: String?, remindIfMiss: Bool, doneDates: [String: Bool] = [:]) {
        self.id = id
        self.title = title
        self.note = note
        self.createdAt = createdAt
        self.friend = friend
        self.schedule = schedule
        self.icon = icon
        self.colorHex = colorHex
        self.days = days
        self.motivation = motivation
        self.remindIfMiss = remindIfMiss
        self.doneDates = doneDates
    }

    init?(from document: [String: Any]) {
        guard let id = document["id"] as? String,
              let title = document["title"] as? String,
              let friend = document["friend"] as? String,
              let icon = document["icon"] as? String,
              let colorHex = document["colorHex"] as? String,
              let scheduleTS = document["schedule"] as? Timestamp,
              let createdAtTS = document["createdAt"] as? Timestamp,
              let daysRaw = document["days"] as? [Any],
              let remindIfMiss = document["remindIfMiss"] as? Bool
        else { return nil }
        self.id = id
        self.title = title
        self.note = document["note"] as? String
        self.createdAt = createdAtTS.dateValue()
        self.friend = friend
        self.schedule = scheduleTS.dateValue()
        self.icon = icon
        self.colorHex = colorHex
        self.days = daysRaw.compactMap {
            if let n = $0 as? NSNumber { return n.intValue }
            if let n = $0 as? Int { return n }
            return nil
        }
        self.motivation = document["motivation"] as? String
        self.remindIfMiss = remindIfMiss
        self.doneDates = document["doneDates"] as? [String: Bool] ?? [:]
    }

    /// Helper for today date string
    static func dateString(for date: Date = Date()) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .current
        return df.string(from: date)
    }

    /// Check if marked done for today
    func isDoneToday() -> Bool {
        doneDates[Habit.dateString()] == true
    }
}
