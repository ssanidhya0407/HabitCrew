//
//  RequestCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol RequestCellDelegate: AnyObject {
    func didTapAcceptButton(for user: User)
    func didTapDeclineButton(for user: User)
}

class RequestCell: UITableViewCell {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let acceptButton = UIButton(type: .system)
    private let declineButton = UIButton(type: .system)
    
    // Properties
    private var user: User?
    weak var delegate: RequestCellDelegate?
    
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
        
        // Accept Button
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = .systemGreen
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 15
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        contentView.addSubview(acceptButton)
        
        // Decline Button
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        declineButton.setTitle("Decline", for: .normal)
        declineButton.backgroundColor = .systemGray5
        declineButton.setTitleColor(.systemRed, for: .normal)
        declineButton.layer.cornerRadius = 15
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        contentView.addSubview(declineButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            declineButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            declineButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            declineButton.widthAnchor.constraint(equalToConstant: 80),
            declineButton.heightAnchor.constraint(equalToConstant: 30),
            
            acceptButton.trailingAnchor.constraint(equalTo: declineButton.leadingAnchor, constant: -10),
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            acceptButton.widthAnchor.constraint(equalToConstant: 80),
            acceptButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with user: User) {
        self.user = user
        
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
    
    @objc private func acceptButtonTapped() {
        guard let user = user else { return }
        delegate?.didTapAcceptButton(for: user)
    }
    
    @objc private func declineButtonTapped() {
        guard let user = user else { return }
        delegate?.didTapDeclineButton(for: user)
    }
}
