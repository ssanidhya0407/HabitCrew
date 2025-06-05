//
//  AddFriendCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol AddFriendCellDelegate: AnyObject {
    func didTapAddButton(for user: User)
}

class AddFriendCell: UITableViewCell {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let emailLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    // Properties
    private var user: User?
    weak var delegate: AddFriendCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
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
        
        // Email Label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont.systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel
        contentView.addSubview(emailLabel)
        
        // Add Button
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 15
        addButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        contentView.addSubview(addButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            usernameLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10),
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            emailLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10),
            emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with user: User) {
        self.user = user
        
        usernameLabel.text = user.username
        emailLabel.text = user.email
        
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
    
    @objc private func addButtonTapped() {
        guard let user = user else { return }
        delegate?.didTapAddButton(for: user)
    }
}
