//
//  User.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import Foundation
import FirebaseFirestore

struct User: Codable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var habits: [String]? // IDs of habits
    var friends: [String]? // IDs of friends
    var pendingFriendRequests: [String]? // IDs of pending friend requests
    
    // Firestore serialization
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "username": username,
            "email": email,
            "profileImageURL": profileImageURL ?? "",
            "habits": habits ?? [],
            "friends": friends ?? [],
            "pendingFriendRequests": pendingFriendRequests ?? []
        ]
    }
    
    static func fromFirestore(data: [String: Any]) -> User? {
        guard 
            let id = data["id"] as? String,
            let username = data["username"] as? String,
            let email = data["email"] as? String
        else { return nil }
        
        let profileImageURL = data["profileImageURL"] as? String
        let habits = data["habits"] as? [String]
        let friends = data["friends"] as? [String]
        let pendingFriendRequests = data["pendingFriendRequests"] as? [String]
        
        return User(
            id: id, 
            username: username, 
            email: email, 
            profileImageURL: profileImageURL, 
            habits: habits, 
            friends: friends, 
            pendingFriendRequests: pendingFriendRequests
        )
    }
}