//
//  MessageService.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import Foundation
import FirebaseFirestore

class MessageService {
    static let shared = MessageService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Send a message to a friend
    func sendMessage(to userId: String, type: MessageType, content: String, completion: @escaping (Result<Message, Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "MessageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let messageId = UUID().uuidString
        let newMessage = Message(
            id: messageId,
            senderId: currentUserId,
            receiverId: userId,
            type: type,
            content: content,
            timestamp: Date(),
            isRead: false
        )
        
        // Store message in Firestore
        db.collection("messages").document(messageId).setData(newMessage.toFirestore()) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(newMessage))
        }
    }
    
    // Get messages between current user and a friend
    func getMessages(with userId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "MessageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // Get messages sent by current user to friend
        db.collection("messages")
            .whereField("senderId", isEqualTo: currentUserId)
            .whereField("receiverId", isEqualTo: userId)
            .getDocuments { [weak self] sentSnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var messages: [Message] = []
                
                for document in sentSnapshot?.documents ?? [] {
                    if let message = Message.fromFirestore(data: document.data()) {
                        messages.append(message)
                    }
                }
                
                // Get messages sent by friend to current user
                self?.db.collection("messages")
                    .whereField("senderId", isEqualTo: userId)
                    .whereField("receiverId", isEqualTo: currentUserId)
                    .getDocuments { receivedSnapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        for document in receivedSnapshot?.documents ?? [] {
                            if let message = Message.fromFirestore(data: document.data()) {
                                messages.append(message)
                                
                                // Mark received messages as read
                                if !message.isRead {
                                    self?.db.collection("messages").document(message.id).updateData([
                                        "isRead": true
                                    ])
                                }
                            }
                        }
                        
                        // Sort messages by timestamp
                        messages.sort { $0.timestamp < $1.timestamp }
                        
                        completion(.success(messages))
                    }
            }
    }
    
    // Setup real-time listener for new messages
    func setupMessagesListener(with userId: String, completion: @escaping (Result<Message, Error>) -> Void) -> ListenerRegistration? {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "MessageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return nil
        }
        
        // Listen for new messages from the friend
        return db.collection("messages")
            .whereField("senderId", isEqualTo: userId)
            .whereField("receiverId", isEqualTo: currentUserId)
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                for change in snapshot?.documentChanges ?? [] where change.type == .added {
                    if let message = Message.fromFirestore(data: change.document.data()) {
                        // Mark message as read
                        self.db.collection("messages").document(message.id).updateData([
                            "isRead": true
                        ])
                        
                        completion(.success(message))
                    }
                }
            }
    }
}