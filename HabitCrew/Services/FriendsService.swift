//
//  FriendsService.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import Foundation
import FirebaseFirestore

class FriendsService {
    static let shared = FriendsService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Send friend request
    func sendFriendRequest(to userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // Add to recipient's pending requests
        db.collection("users").document(userId).updateData([
            "pendingFriendRequests": FieldValue.arrayUnion([currentUserId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // Accept friend request
    func acceptFriendRequest(from userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // Remove from pending requests
        db.collection("users").document(currentUserId).updateData([
            "pendingFriendRequests": FieldValue.arrayRemove([userId]),
            "friends": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Add to sender's friends list as well
            self.db.collection("users").document(userId).updateData([
                "friends": FieldValue.arrayUnion([currentUserId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    // Decline friend request
    func declineFriendRequest(from userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // Just remove from pending requests
        db.collection("users").document(currentUserId).updateData([
            "pendingFriendRequests": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // Get friends list
    func getFriends(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // First get the current user's friends IDs
        db.collection("users").document(currentUserId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                return
            }
            
            let friendIds = data["friends"] as? [String] ?? []
            
            if friendIds.isEmpty {
                completion(.success([]))
                return
            }
            
            // Then get the details for each friend
            self.db.collection("users").whereField(FieldPath.documentID(), in: friendIds).getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var friends: [User] = []
                
                for document in snapshot?.documents ?? [] {
                    if let user = User.fromFirestore(data: document.data()) {
                        friends.append(user)
                    }
                }
                
                completion(.success(friends))
            }
        }
    }
    
    // Get pending friend requests
    func getPendingFriendRequests(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // First get the current user's pending friend requests IDs
        db.collection("users").document(currentUserId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "FriendsError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                return
            }
            
            let pendingFriendRequestsIds = data["pendingFriendRequests"] as? [String] ?? []
            
            if pendingFriendRequestsIds.isEmpty {
                completion(.success([]))
                return
            }
            
            // Then get the details for each pending friend request
            self.db.collection("users").whereField(FieldPath.documentID(), in: pendingFriendRequestsIds).getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var pendingFriendRequests: [User] = []
                
                for document in snapshot?.documents ?? [] {
                    if let user = User.fromFirestore(data: document.data()) {
                        pendingFriendRequests.append(user)
                    }
                }
                
                completion(.success(pendingFriendRequests))
            }
        }
    }
}