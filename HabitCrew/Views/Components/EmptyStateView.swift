//
//  EmptyStateView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  EmptyStateView.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Empty State View - Beautiful empty state for no habits
//

import UIKit

/// Beautiful empty state view with illustration and call-to-action
class EmptyStateView: UIView {
    
    // MARK: - Properties
    
    private let containerView = UIView()
    private let illustrationImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = PillButton.primary(title: "Add Your First Habit")
    
    var onActionTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    init(title: String = "No habits yet", message: String = "Start building better habits today", actionTitle: String = "Add Your First Habit") {
        super.init(frame: .zero)
        setupEmptyState(title: title, message: message, actionTitle: actionTitle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEmptyState(title: "No habits yet", message: "Start building better habits today", actionTitle: "Add Your First Habit")
    }
    
    // MARK: - Setup
    
    private func setupEmptyState(title: String, message: String, actionTitle: String) {
        backgroundColor = .clear
        
        setupLayout()
        setupContent(title: title, message: message, actionTitle: actionTitle)
        setupAccessibility()
    }
    
    private func setupLayout() {
        // Container for centering
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Illustration
        illustrationImageView.translatesAutoresizingMaskIntoConstraints = false
        illustrationImageView.contentMode = .scaleAspectFit
        illustrationImageView.tintColor = .textTertiary
        containerView.addSubview(illustrationImageView)
        
        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .headline
        titleLabel.textColor = .textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        // Message label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .body
        messageLabel.textColor = .textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        containerView.addSubview(messageLabel)
        
        // Action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        containerView.addSubview(actionButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Spacing.large),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Spacing.large),
            
            // Illustration
            illustrationImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            illustrationImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            illustrationImageView.widthAnchor.constraint(equalToConstant: 120),
            illustrationImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: illustrationImageView.bottomAnchor, constant: Spacing.large),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Message
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.small),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Action button
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Spacing.xLarge),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
    
    private func setupContent(title: String, message: String, actionTitle: String) {
        titleLabel.text = title
        messageLabel.text = message
        actionButton.setText(actionTitle)
        
        // Set illustration based on context
        setupIllustration()
    }
    
    private func setupIllustration() {
        // Create a custom illustration view with SF Symbols
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        illustrationImageView.image = UIImage(systemName: "target", withConfiguration: config)
        
        // Add subtle animation
        addFloatingAnimation()
    }
    
    private func setupAccessibility() {
        // Make the container accessible
        isAccessibilityElement = false
        accessibilityElements = [titleLabel, messageLabel, actionButton]
        
        titleLabel.accessibilityTraits = [.header]
    }
    
    // MARK: - Animations
    
    private func addFloatingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -8
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        illustrationImageView.layer.add(animation, forKey: "floating")
    }
    
    /// Animates the empty state into view
    func animateIn(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(
            withDuration: 0.8,
            delay: delay,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction],
            animations: {
                self.alpha = 1
                self.transform = .identity
            }
        )
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        onActionTapped?()
    }
    
    // MARK: - Public Methods
    
    func updateContent(title: String? = nil, message: String? = nil, actionTitle: String? = nil) {
        if let title = title {
            titleLabel.text = title
        }
        
        if let message = message {
            messageLabel.text = message
        }
        
        if let actionTitle = actionTitle {
            actionButton.setText(actionTitle)
        }
    }
    
    func setIllustration(_ imageName: String, pointSize: CGFloat = 80) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .light)
        illustrationImageView.image = UIImage(systemName: imageName, withConfiguration: config)
    }
    
    func hideActionButton(_ hidden: Bool = true) {
        actionButton.isHidden = hidden
    }
}

// MARK: - Factory Methods

extension EmptyStateView {
    
    /// Empty state for no habits
    static func noHabits() -> EmptyStateView {
        let view = EmptyStateView(
            title: "No habits yet",
            message: "Start building better habits today.\nEvery small step counts!",
            actionTitle: "Add Your First Habit"
        )
        view.setIllustration("target")
        return view
    }
    
    /// Empty state for completed habits
    static func allCompleted() -> EmptyStateView {
        let view = EmptyStateView(
            title: "All done! 🎉",
            message: "You've completed all your habits for today.\nGreat job staying consistent!",
            actionTitle: "Add Another Habit"
        )
        view.setIllustration("checkmark.circle")
        return view
    }
    
    /// Empty state for no habits today
    static func noHabitsToday() -> EmptyStateView {
        let view = EmptyStateView(
            title: "No habits for today",
            message: "You don't have any habits scheduled for today.\nTake a well-deserved break or add a new habit!",
            actionTitle: "Add a Habit"
        )
        view.setIllustration("calendar.badge.plus")
        return view
    }
    
    /// Empty state for search results
    static func noSearchResults() -> EmptyStateView {
        let view = EmptyStateView(
            title: "No results found",
            message: "Try adjusting your search terms or create a new habit.",
            actionTitle: "Create New Habit"
        )
        view.setIllustration("magnifyingglass")
        return view
    }
}