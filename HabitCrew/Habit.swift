import Foundation
import FirebaseFirestore

struct Habit {
    let id: String
    let title: String
    let note: String?
    let createdAt: Date
    let friend: String
    let schedule: Date
    let icon: String
    let colorHex: String
    let days: [Int]
    let motivation: String?
    let remindIfMiss: Bool
    var doneDates: [String: Bool]
    var isPublic: Bool  // <-- Add this field for privacy/public toggle

    init(
        id: String = UUID().uuidString,
        title: String,
        note: String? = nil,
        createdAt: Date = Date(),
        friend: String = "",
        schedule: Date,
        icon: String = "star.fill",
        colorHex: String = "#3B6DF6",
        days: [Int] = [],
        motivation: String? = nil,
        remindIfMiss: Bool = true,
        doneDates: [String: Bool] = [:],
        isPublic: Bool = true  // <-- default to true (public)
    ) {
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
        self.isPublic = isPublic
    }

    init?(from dict: [String: Any]) {
        self.id = dict["id"] as? String ?? UUID().uuidString
        self.title = dict["title"] as? String ?? ""
        self.note = dict["note"] as? String
        if let ts = dict["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }
        self.friend = dict["friend"] as? String ?? ""
        if let ts = dict["schedule"] as? Timestamp {
            self.schedule = ts.dateValue()
        } else {
            self.schedule = Date()
        }
        self.icon = dict["icon"] as? String ?? "star.fill"
        self.colorHex = dict["colorHex"] as? String ?? "#3B6DF6"
        self.days = dict["days"] as? [Int] ?? []
        self.motivation = dict["motivation"] as? String
        self.remindIfMiss = dict["remindIfMiss"] as? Bool ?? true
        self.doneDates = dict["doneDates"] as? [String: Bool] ?? [:]
        self.isPublic = dict["isPublic"] as? Bool ?? true  // <-- read from Firestore, default true
    }

    var dictionary: [String: Any] {
        return [
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
            "doneDates": doneDates,
            "isPublic": isPublic    // <-- save to Firestore
        ]
    }

    func isDoneToday() -> Bool {
        let today = Habit.dateString()
        return doneDates[today] == true
    }

    static func dateString(for date: Date = Date()) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
}
