//
//  BuddyCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class BuddyCell: UITableViewCell {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    private let skeletonLayerColor = UIColor.systemGray5.cgColor
    private var skeletonLayers: [CALayer] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove skeleton layers
        for layer in skeletonLayers {
            layer.removeFromSuperlayer()
        }
        skeletonLayers.removeAll()
        
        usernameLabel.text = nil
        checkmarkImageView.isHidden = true
    }
    
    private func setupUI() {
        // Profile Image View
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.backgroundColor = .systemGray4
        contentView.addSubview(profileImageView)
        
        // Username Label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(usernameLabel)
        
        // Checkmark Image View
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemBlue
        checkmarkImageView.isHidden = true
        contentView.addSubview(checkmarkImageView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -15),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with user: User, isSelected: Bool) {
        usernameLabel.text = user.username
        checkmarkImageView.isHidden = !isSelected
        
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
    
    func showSkeleton() {
        // Create and add skeleton layers
        let nameLayer = CALayer()
        nameLayer.frame = CGRect(x: 70, y: 20, width: contentView.bounds.width - 120, height: 20)
        nameLayer.backgroundColor = skeletonLayerColor
        nameLayer.cornerRadius = 4
        
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 15, y: 10, width: 40, height: 40)
        imageLayer.backgroundColor = skeletonLayerColor
        imageLayer.cornerRadius = 20
        
        contentView.layer.addSublayer(nameLayer)
        contentView.layer.addSublayer(imageLayer)
        
        skeletonLayers = [nameLayer, imageLayer]
        
        // Add animation
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.6
        animation.toValue = 0.3
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        for layer in skeletonLayers {
            layer.add(animation, forKey: "pulsating")
        }
    }
}