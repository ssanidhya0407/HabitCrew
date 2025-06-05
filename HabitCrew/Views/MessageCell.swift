//
//  MessageCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class MessageCell: UITableViewCell {
    
    // UI Components
    private let messageView = UIView()
    private let messageTextLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Message View
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.layer.cornerRadius = 16
        contentView.addSubview(messageView)
        
        // Message Text Label
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.numberOfLines = 0
        messageView.addSubview(messageTextLabel)
        
        // Time Label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = .secondaryLabel
        contentView.addSubview(timeLabel)
        
        // Default constraints - will be updated in configure
        NSLayoutConstraint.activate([
            messageTextLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 8),
            messageTextLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 12),
            messageTextLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -12),
            messageTextLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: Message, isCurrentUser: Bool) {
        messageTextLabel.text = message.content
        
        // Format time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // Determine layout and styling based on sender
        if isCurrentUser {
            messageView.backgroundColor = UIColor.systemBlue
            messageTextLabel.textColor = .white
            
            // Layout for current user (right-aligned)
            NSLayoutConstraint.activate([
                messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                messageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
                
                timeLabel.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 2),
                timeLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        } else {
            messageView.backgroundColor = UIColor.systemGray6
            messageTextLabel.textColor = .label
            
            // Layout for other user (left-aligned)
            NSLayoutConstraint.activate([
                messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                messageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
                
                timeLabel.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 2),
                timeLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    }
}