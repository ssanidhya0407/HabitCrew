//
//  HabitService.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import Foundation
import FirebaseFirestore

class HabitService {
    static let shared = HabitService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Create a new habit with optional additional data for custom frequency
    func createHabit(
        title: String,
        description: String?,
        frequency: HabitFrequency,
        color: String,
        icon: String,
        buddyIds: [String]?,
        additionalData: [String: Any]? = nil,
        completion: @escaping (Result<Habit, Error>) -> Void
    ) {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let habitId = UUID().uuidString
        let newHabit = Habit(
            id: habitId,
            title: title,
            description: description,
            ownerId: userId,
            buddyIds: buddyIds,
            frequency: frequency,
            color: color,
            icon: icon,
            startDate: Date(),
            completedDates: [],
            streak: 0
        )
        
        // Convert habit to Firestore data
        var habitData = newHabit.toFirestore()
        
        // Add any additional custom data
        if let additionalData = additionalData {
            for (key, value) in additionalData {
                habitData[key] = value
            }
        }
        
        // Store habit in Firestore
        db.collection("habits").document(habitId).setData(habitData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update user's habits array
            self.db.collection("users").document(userId).updateData([
                "habits": FieldValue.arrayUnion([habitId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Also update habits array for buddies if they exist
                if let buddyIds = buddyIds, !buddyIds.isEmpty {
                    for buddyId in buddyIds {
                        self.db.collection("users").document(buddyId).updateData([
                            "habits": FieldValue.arrayUnion([habitId])
                        ])
                    }
                }
                
                completion(.success(newHabit))
            }
        }
    }
    
    // Get all habits for the current user
    func getHabits(completion: @escaping (Result<[Habit], Error>) -> Void) {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        db.collection("habits")
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var habits: [Habit] = []
                
                for document in snapshot?.documents ?? [] {
                    if let habit = Habit.fromFirestore(data: document.data()) {
                        habits.append(habit)
                    }
                }
                
                // Also get habits where the user is a buddy
                self.db.collection("habits")
                    .whereField("buddyIds", arrayContains: userId)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        for document in snapshot?.documents ?? [] {
                            if let habit = Habit.fromFirestore(data: document.data()) {
                                habits.append(habit)
                            }
                        }
                        
                        completion(.success(habits))
                    }
            }
    }
    
    // Mark a habit as completed for today
    func completeHabit(habitId: String, completion: @escaping (Result<Habit, Error>) -> Void) {
        db.collection("habits").document(habitId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Habit not found"])))
                return
            }
            
            guard var habit = Habit.fromFirestore(data: data) else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse habit data"])))
                return
            }
            
            // Check if already completed today
            if !habit.isCompletedToday() {
                let today = Date()
                
                // Update streak
                let calendar = Calendar.current
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                
                let wasCompletedYesterday = habit.completedDates.contains { date in
                    calendar.isDate(date, inSameDayAs: yesterday)
                }
                
                if wasCompletedYesterday || habit.streak == 0 {
                    habit.streak += 1
                }
                
                // Update completedDates
                habit.completedDates.append(today)
                
                // Update in Firestore
                self.db.collection("habits").document(habitId).updateData([
                    "completedDates": habit.completedDates.map { Timestamp(date: $0) },
                    "streak": habit.streak
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(habit))
                }
            } else {
                completion(.success(habit)) // Already completed today
            }
        }
    }
    
    // Edit an existing habit with support for custom frequency data
    func updateHabit(
        habit: Habit,
        additionalData: [String: Any]? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var habitData = habit.toFirestore()
        
        // Add any additional custom data
        if let additionalData = additionalData {
            for (key, value) in additionalData {
                habitData[key] = value
            }
        }
        
        db.collection("habits").document(habit.id).updateData(habitData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // Delete a habit
    func deleteHabit(habitId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // Get habit to check buddyIds
        db.collection("habits").document(habitId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Habit not found"])))
                return
            }
            
            guard let habit = Habit.fromFirestore(data: data) else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse habit data"])))
                return
            }
            
            // Delete habit document
            self.db.collection("habits").document(habitId).delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Remove from owner's habits array
                self.db.collection("users").document(userId).updateData([
                    "habits": FieldValue.arrayRemove([habitId])
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // Also remove from buddies if they exist
                    if let buddyIds = habit.buddyIds, !buddyIds.isEmpty {
                        for buddyId in buddyIds {
                            self.db.collection("users").document(buddyId).updateData([
                                "habits": FieldValue.arrayRemove([habitId])
                            ])
                        }
                    }
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    // Check if a habit should be completed today based on its frequency
    // This is useful for custom frequency habits
    func shouldCompleteToday(habit: Habit, completion: @escaping (Result<Bool, Error>) -> Void) {
        // For regular frequencies, use the default isCompletedToday logic
        if habit.frequency != .custom {
            let shouldComplete = !habit.isCompletedToday()
            completion(.success(shouldComplete))
            return
        }
        
        // For custom frequency, check if today is one of the selected days
        db.collection("habits").document(habit.id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Habit not found"])))
                return
            }
            
            // Get custom days (0 = Sunday, 1 = Monday, etc.)
            guard let customDays = data["customDays"] as? [Int] else {
                completion(.success(false))
                return
            }
            
            // Check if today is one of the selected days
            let calendar = Calendar.current
            let today = calendar.component(.weekday, from: Date()) - 1 // Convert to 0-based (0 = Sunday)
            let shouldComplete = customDays.contains(today) && !habit.isCompletedToday()
            
            completion(.success(shouldComplete))
        }
    }
    
    // Get custom frequency data for a habit
    func getHabitCustomFrequencyData(habitId: String, completion: @escaping (Result<(days: [Int], times: [Date], reminderEnabled: Bool), Error>) -> Void) {
        db.collection("habits").document(habitId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Habit not found"])))
                return
            }
            
            // Get custom days
            guard let customDays = data["customDays"] as? [Int] else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Custom days not found"])))
                return
            }
            
            // Get custom times
            guard let customTimeIntervals = data["customTimes"] as? [Double] else {
                completion(.failure(NSError(domain: "HabitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Custom times not found"])))
                return
            }
            
            // Convert time intervals to Date objects
            let customTimes = customTimeIntervals.map { Date(timeIntervalSince1970: $0) }
            
            // Get reminder enabled status
            let reminderEnabled = data["reminderEnabled"] as? Bool ?? true
            
            completion(.success((customDays, customTimes, reminderEnabled)))
        }
    }
}
