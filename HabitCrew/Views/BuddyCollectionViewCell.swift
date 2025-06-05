//
//  BuddyCollectionViewCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class BuddyCollectionViewCell: UICollectionViewCell {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Profile Image View
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 25
        profileImageView.backgroundColor = .systemGray4
        contentView.addSubview(profileImageView)
        
        // Username Label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        usernameLabel.textAlignment = .center
        usernameLabel.numberOfLines = 1
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.8
        contentView.addSubview(usernameLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            usernameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(with user: User) {
        usernameLabel.text = user.username
        
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
    }
    
    func configureAsEmpty() {
        profileImageView.image = UIImage(systemName: "person.badge.plus")
        profileImageView.tintColor = .systemGray
        usernameLabel.text = "No buddies"
    }
}