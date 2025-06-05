//
//  TaskHabitCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol TaskHabitCellDelegate: AnyObject {
    func didTapCompleteButton(for habit: Habit)
}

class TaskHabitCell: UITableViewCell {
    
    // UI Components
    private let cardView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let streakView = UIView()
    private let streakLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private let progressView = UIProgressView()
    
    // Data
    private var habit: Habit?
    private let skeletonLayerColor = UIColor.systemGray5.cgColor
    private var skeletonLayers: [CALayer] = []
    
    weak var delegate: TaskHabitCellDelegate?
    
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
        
        // Reset content
        titleLabel.text = nil
        detailsLabel.text = nil
        streakLabel.text = nil
        progressView.progress = 0
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Card View
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(cardView)
        
        // Icon Container
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        iconContainerView.layer.cornerRadius = 24
        cardView.addSubview(iconContainerView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconContainerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 1
        cardView.addSubview(titleLabel)
        
        // Details Label
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.numberOfLines = 1
        cardView.addSubview(detailsLabel)
        
        // Streak View
        streakView.translatesAutoresizingMaskIntoConstraints = false
        streakView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        streakView.layer.cornerRadius = 12
        cardView.addSubview(streakView)
        
        // Streak Label
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        streakLabel.textColor = .systemOrange
        streakLabel.textAlignment = .center
        streakView.addSubview(streakLabel)
        
        // Complete Button
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.backgroundColor = .clear
        completeButton.tintColor = .systemGray2
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        cardView.addSubview(completeButton)
        
        // Progress View
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemBlue
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        cardView.addSubview(progressView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: -8),
            
            streakView.centerYAnchor.constraint(equalTo: detailsLabel.centerYAnchor),
            streakView.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
            streakView.heightAnchor.constraint(equalToConstant: 24),
            streakView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            streakLabel.topAnchor.constraint(equalTo: streakView.topAnchor),
            streakLabel.leadingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: 8),
            streakLabel.trailingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: -8),
            streakLabel.bottomAnchor.constraint(equalTo: streakView.bottomAnchor),
            
            completeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            completeButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 44),
            completeButton.heightAnchor.constraint(equalToConstant: 44),
            
            progressView.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func configure(with habit: Habit) {
        self.habit = habit
        
        // Set text content
        titleLabel.text = habit.title
        
        // Format details based on frequency
        switch habit.frequency {
        case .daily:
            detailsLabel.text = "Every day"
        case .weekly:
            let weekday = Calendar.current.component(.weekday, from: habit.startDate)
            let weekdayName = DateFormatter().weekdaySymbols[weekday - 1]
            detailsLabel.text = "Every \(weekdayName)"
        case .monthly:
            let day = Calendar.current.component(.day, from: habit.startDate)
            detailsLabel.text = "Every \(day)\(daySuffix(for: day)) day"
        case .custom:
            detailsLabel.text = "Custom schedule"
        }
        
        // Set streak label
        streakLabel.text = "🔥 \(habit.streak)"
        
        // Set icon and color
        iconImageView.image = UIImage(systemName: habit.icon)
        
        if let uiColor = UIColor(hex: habit.color) {
            iconContainerView.backgroundColor = uiColor.withAlphaComponent(0.15)
            iconImageView.tintColor = uiColor
            progressView.progressTintColor = uiColor
        }
        
        // Set completion status
        let isCompleted = habit.isCompletedToday()
        completeButton.setImage(
            UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        completeButton.tintColor = isCompleted ? .systemGreen : .systemGray2
        
        // Set progress
        progressView.progress = isCompleted ? 1.0 : 0.0
    }
    
    private func daySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    func showSkeleton() {
        // Create skeleton layers
        let titleLayer = CALayer()
        titleLayer.frame = CGRect(x: 80, y: 16, width: contentView.bounds.width - 160, height: 18)
        titleLayer.backgroundColor = skeletonLayerColor
        titleLayer.cornerRadius = 4
        
        let detailsLayer = CALayer()
        detailsLayer.frame = CGRect(x: 80, y: 42, width: contentView.bounds.width - 200, height: 14)
        detailsLayer.backgroundColor = skeletonLayerColor
        detailsLayer.cornerRadius = 4
        
        let streakLayer = CALayer()
        streakLayer.frame = CGRect(x: contentView.bounds.width - 130, y: 42, width: 60, height: 18)
        streakLayer.backgroundColor = skeletonLayerColor
        streakLayer.cornerRadius = 9
        
        let iconLayer = CALayer()
        iconLayer.frame = CGRect(x: 16, y: 20, width: 48, height: 48)
        iconLayer.backgroundColor = skeletonLayerColor
        iconLayer.cornerRadius = 24
        
        let buttonLayer = CALayer()
        buttonLayer.frame = CGRect(x: contentView.bounds.width - 64, y: 24, width: 44, height: 44)
        buttonLayer.backgroundColor = skeletonLayerColor
        buttonLayer.cornerRadius = 22
        
        let progressLayer = CALayer()
        progressLayer.frame = CGRect(x: 80, y: contentView.bounds.height - 24, width: contentView.bounds.width - 96, height: 4)
        progressLayer.backgroundColor = skeletonLayerColor
        progressLayer.cornerRadius = 2
        
        cardView.layer.addSublayer(titleLayer)
        cardView.layer.addSublayer(detailsLayer)
        cardView.layer.addSublayer(streakLayer)
        cardView.layer.addSublayer(iconLayer)
        cardView.layer.addSublayer(buttonLayer)
        cardView.layer.addSublayer(progressLayer)
        
        skeletonLayers = [titleLayer, detailsLayer, streakLayer, iconLayer, buttonLayer, progressLayer]
        
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
    
    @objc private func completeButtonTapped() {
        guard let habit = habit else { return }
        delegate?.didTapCompleteButton(for: habit)
    }
}
