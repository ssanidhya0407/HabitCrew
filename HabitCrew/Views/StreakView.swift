//
//  StreakView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class StreakView: UIView {
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let streakLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        containerView.layer.cornerRadius = 16
        addSubview(containerView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(systemName: "flame.fill")
        iconImageView.tintColor = .white
        containerView.addSubview(iconImageView)
        
        // Streak Label
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        streakLabel.textColor = .white
        streakLabel.textAlignment = .right
        containerView.addSubview(streakLabel)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white.withAlphaComponent(0.9)
        titleLabel.text = "Current Streak"
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -4),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            streakLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            streakLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            streakLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(streakCount: Int) {
        streakLabel.text = String(streakCount)
    }
}