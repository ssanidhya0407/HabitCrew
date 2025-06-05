//
//  AuthService.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    var currentUser: User?
    
    private init() {}
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authResult = result else {
                completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authentication error"])))
                return
            }
            
            let userId = authResult.user.uid
            let newUser = User(
                id: userId,
                username: username,
                email: email,
                profileImageURL: nil,
                habits: nil,
                friends: nil,
                pendingFriendRequests: nil
            )
            
            // Store user in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(userId).setData(newUser.toFirestore()) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                self?.currentUser = newUser
                completion(.success(newUser))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let userId = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            // Fetch user data from Firestore
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let userData = document.data() else {
                    completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                    return
                }
                
                if let user = User.fromFirestore(data: userData) {
                    self?.currentUser = user
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user data"])))
                }
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
