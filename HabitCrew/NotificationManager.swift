//
//  NotificationManager.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 26/06/25.
//


import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

class NotificationManager {
    static let shared = NotificationManager()
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleHabitNotification(for habit: Habit) {
        // Request permission if we haven't already
        requestAuthorization { granted in
            guard granted else { 
                print("Notification permission denied")
                return
            }
            
            // Cancel existing notifications for this habit
            self.cancelNotification(for: habit.id)
            
            // Get which days the notification should be scheduled for
            let days = habit.days
            
            // Current day of week (0-6, 0 is Sunday in our app)
            let calendar = Calendar.current
            let today = (calendar.component(.weekday, from: Date()) + 6) % 7
            
            // For each scheduled day, create a notification
            for day in days {
                // Calculate days until this day of the week
                var daysToAdd = (day - today + 7) % 7
                if daysToAdd == 0 {
                    // If today is a scheduled day, check if the time has already passed
                    let now = Date()
                    if now > habit.schedule {
                        // If we missed today's notification, schedule for next week
                        daysToAdd = 7
                    }
                }
                
                // Get the next date component for this day of the week
                var dateComponents = calendar.dateComponents([.hour, .minute], from: habit.schedule)
                dateComponents.weekday = ((day + 1) % 7) + 1 // Convert to Calendar.weekday (1-7, 1 is Sunday)
                
                // Create notification content
                let content = UNMutableNotificationContent()
                content.title = "Time for \(habit.title)"
                content.body = habit.note ?? "It's time for your habit!"
                content.sound = .default
                content.badge = 1
                
                // Store habit info in user info
                content.userInfo = [
                    "habitId": habit.id,
                    "habitTitle": habit.title,
                    "habitColorHex": habit.colorHex
                ]
                
                // Create trigger
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                // Create request
                let requestIdentifier = "habit-\(habit.id)-day-\(day)"
                let request = UNNotificationRequest(
                    identifier: requestIdentifier,
                    content: content,
                    trigger: trigger
                )
                
                // Schedule notification
                self.userNotificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
    
    func cancelNotification(for habitId: String) {
        userNotificationCenter.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix("habit-\(habitId)") }
                .map { $0.identifier }
            
            self.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func cancelAllHabitNotifications() {
        userNotificationCenter.removeAllPendingNotificationRequests()
    }
    
    func storeNotification(_ notification: UNNotification) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let content = notification.request.content
        let userInfo = content.userInfo
        
        guard let habitId = userInfo["habitId"] as? String,
              let habitTitle = userInfo["habitTitle"] as? String,
              let habitColorHex = userInfo["habitColorHex"] as? String else {
            return
        }
        
        // Create a notification document
        let notificationData: [String: Any] = [
            "title": content.title,
            "message": content.body,
            "timestamp": Timestamp(date: notification.date),
            "habitId": habitId,
            "habitTitle": habitTitle,
            "habitColorHex": habitColorHex,
            "isRead": false
        ]
        
        // Add to Firestore
        db.collection("users").document(uid).collection("notifications")
            .addDocument(data: notificationData) { error in
                if let error = error {
                    print("Error storing notification: \(error)")
                }
            }
    }
    
    func getNotificationBadgeCount(completion: @escaping (Int) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(0)
            return
        }
        
        // Get count of unread notifications
        db.collection("users").document(uid).collection("notifications")
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting badge count: \(error)")
                    completion(0)
                    return
                }
                
                completion(snapshot?.documents.count ?? 0)
            }
    }
}