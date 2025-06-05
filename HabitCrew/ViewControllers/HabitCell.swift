//
//  HabitCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol HabitCellDelegate: AnyObject {
    func didTapCompleteButton(for habit: Habit)
}

class HabitCell: UITableViewCell {
    
    // UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    private let completeButton = UIButton()
    private let buddyStackView = UIStackView()
    
    // Properties
    private var habit: Habit?
    weak var delegate: HabitCellDelegate?
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
        
        // Remove any skeleton layers
        for layer in skeletonLayers {
            layer.removeFromSuperlayer()
        }
        skeletonLayers.removeAll()
        
        // Reset content visibility
        titleLabel.text = nil
        streakLabel.text = nil
        iconImageView.image = nil
        for view in buddyStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        // Reset container appearance
        containerView.backgroundColor = .systemBackground
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        contentView.addSubview(containerView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        containerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        containerView.addSubview(titleLabel)
        
        // Streak Label
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        streakLabel.textColor = .secondaryLabel
        containerView.addSubview(streakLabel)
        
        // Complete Button
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        completeButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        completeButton.tintColor = .systemBlue
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        containerView.addSubview(completeButton)
        
        // Buddy Stack View
        buddyStackView.translatesAutoresizingMaskIntoConstraints = false
        buddyStackView.axis = .horizontal
        buddyStackView.spacing = -10
        buddyStackView.distribution = .fillProportionally
        containerView.addSubview(buddyStackView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -12),
            
            streakLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            streakLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            
            buddyStackView.leadingAnchor.constraint(equalTo: streakLabel.trailingAnchor, constant: 12),
            buddyStackView.centerYAnchor.constraint(equalTo: streakLabel.centerYAnchor),
            buddyStackView.heightAnchor.constraint(equalToConstant: 24),
            
            completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 44),
            completeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(with habit: Habit) {
        self.habit = habit
        
        // Configure UI with habit data
        titleLabel.text = habit.title
        streakLabel.text = "🔥 \(habit.streak) day streak"
        iconImageView.image = UIImage(systemName: habit.icon)
        completeButton.isSelected = habit.isCompletedToday()
        
        // Set container color based on habit color
        if let uiColor = UIColor(hex: habit.color) {
            containerView.layer.borderColor = uiColor.cgColor
            iconImageView.tintColor = uiColor
        }
        
        // Add buddy avatars if available
        if let buddyIds = habit.buddyIds, !buddyIds.isEmpty {
            for _ in buddyIds {
                let avatarView = UIImageView()
                avatarView.translatesAutoresizingMaskIntoConstraints = false
                avatarView.contentMode = .scaleAspectFill
                avatarView.backgroundColor = .systemGray3
                avatarView.layer.cornerRadius = 12
                avatarView.layer.borderWidth = 2
                avatarView.layer.borderColor = UIColor.systemBackground.cgColor
                avatarView.clipsToBounds = true
                avatarView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                avatarView.heightAnchor.constraint(equalToConstant: 24).isActive = true
                
                // In a real app, you would load the buddy's avatar here
                avatarView.image = UIImage(systemName: "person.fill")
                avatarView.tintColor = .white
                
                buddyStackView.addArrangedSubview(avatarView)
            }
        }
    }
    
    func showSkeleton() {
        // Create and add skeleton layers
        let titleLayer = CALayer()
        titleLayer.frame = CGRect(x: 56, y: 16, width: 200, height: 20)
        titleLayer.backgroundColor = skeletonLayerColor
        titleLayer.cornerRadius = 4
        
        let streakLayer = CALayer()
        streakLayer.frame = CGRect(x: 56, y: 40, width: 120, height: 16)
        streakLayer.backgroundColor = skeletonLayerColor
        streakLayer.cornerRadius = 4
        
        let iconLayer = CALayer()
        iconLayer.frame = CGRect(x: 12, y: 34, width: 32, height: 32)
        iconLayer.backgroundColor = skeletonLayerColor
        iconLayer.cornerRadius = 16
        
        let completeLayer = CALayer()
        completeLayer.frame = CGRect(x: containerView.bounds.width - 56, y: 28, width: 44, height: 44)
        completeLayer.backgroundColor = skeletonLayerColor
        completeLayer.cornerRadius = 22
        
        containerView.layer.addSublayer(titleLayer)
        containerView.layer.addSublayer(streakLayer)
        containerView.layer.addSublayer(iconLayer)
        containerView.layer.addSublayer(completeLayer)
        
        skeletonLayers = [titleLayer, streakLayer, iconLayer, completeLayer]
        
        // Add animation to skeleton layers
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
    
    @objc private func completeButtonTapped() {
        guard let habit = habit else { return }
        
        // Toggle selected state visually (will be updated by service call)
        completeButton.isSelected = !completeButton.isSelected
        
        delegate?.didTapCompleteButton(for: habit)
    }
}

// UIColor extension for hex color support
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
