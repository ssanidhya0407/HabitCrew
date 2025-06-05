//
//  FriendCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class FriendCell: UITableViewCell {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let statusLabel = UILabel()
    private let unreadBadge = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        // Profile Image View
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 25
        profileImageView.backgroundColor = .systemGray4
        contentView.addSubview(profileImageView)
        
        // Username Label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(usernameLabel)
        
        // Status Label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        contentView.addSubview(statusLabel)
        
        // Unread Badge
        unreadBadge.translatesAutoresizingMaskIntoConstraints = false
        unreadBadge.backgroundColor = .systemBlue
        unreadBadge.layer.cornerRadius = 10
        unreadBadge.isHidden = true
        contentView.addSubview(unreadBadge)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            usernameLabel.trailingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: -10),
            
            statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            unreadBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            unreadBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unreadBadge.widthAnchor.constraint(equalToConstant: 20),
            unreadBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with user: User) {
        usernameLabel.text = user.username
        statusLabel.text = "Tap to chat"
        
        // Set profile image if available
        if let profileImageURL = user.profileImageURL, let url = URL(string: profileImageURL) {
            // In a real app, use SDWebImage or another library to load image
            // For now, just set a placeholder
            profileImageView.image = UIImage(systemName: "person.fill")
            profileImageView.tintColor = .systemBlue
        } else {
            // Default image
            profileImageView.image = UIImage(systemName: "person.fill")
            profileImageView.tintColor = .systemBlue
        }
        
        // Check for unread messages (this would be implemented with Firebase)
        unreadBadge.isHidden = true // For now, just hide it
    }
}