//
//  AppDelegate.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 13/06/25.
//

import UIKit
import Firebase
import FirebaseAuth
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Local notification setup
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else if !granted {
                print("User denied notification permissions")
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle (if using scenes)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Show banners in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent called with content: \(notification.request.content)")
        completionHandler([.banner, .sound, .list])
    }

    // MARK: - Presence logic
    func setPresenceOnline(_ online: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        if online {
            db.collection("users").document(uid).setData([
                "isOnline": true
            ], merge: true)
        } else {
            db.collection("users").document(uid).setData([
                "isOnline": false,
                "lastSeen": FieldValue.serverTimestamp()
            ], merge: true)
        }
    }
}
