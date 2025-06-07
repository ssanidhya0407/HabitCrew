//
//  HabitCardView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//

//
//  HabitCardView.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Modern Habit Card Component - Redesigned with gradients and smooth interactions
//

import UIKit

/// Modern habit card with gradient background and smooth animations
class HabitCardView: BaseCard {
    
    // MARK: - Properties
    
    private let gradientView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let progressIndicator = ProgressIndicator.ring(diameter: 60, lineWidth: 6)
    private let streakContainer = UIView()
    private let streakLabel = UILabel()
    private let checkboxButton = UIButton()
    
    private var habit: Habit?
    private var gradientLayer: CAGradientLayer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    weak var delegate: HabitCardViewDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHabitCard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHabitCard()
    }
    
    // MARK: - Setup
    
    private func setupHabitCard() {
        setupCardLayout()
        setupInteractions()
        setupAccessibility()
    }
    
    private func setupCardLayout() {
        // Clear default card styling for custom gradient
        backgroundColor = .clear
        applyShadow(.standard)
        applyCornerRadius(.card)
        
        // Gradient background view
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.cornerRadius = CornerRadius.Component.card
        gradientView.layer.masksToBounds = true
        addSubview(gradientView)
        
        // Icon container with circular background
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 24
        addSubview(iconContainer)
        
        // Icon image view
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainer.addSubview(iconImageView)
        
        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .title
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        
        // Description label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .bodySmall
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 1
        addSubview(descriptionLabel)
        
        // Progress indicator
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.progressColor = .white
        progressIndicator.trackColor = UIColor.white.withAlphaComponent(0.3)
        progressIndicator.useGradient = false
        addSubview(progressIndicator)
        
        // Streak container
        streakContainer.translatesAutoresizingMaskIntoConstraints = false
        streakContainer.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        streakContainer.layer.cornerRadius = 12
        addSubview(streakContainer)
        
        // Streak label
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = .caption
        streakLabel.textColor = .white
        streakLabel.textAlignment = .center
        streakContainer.addSubview(streakLabel)
        
        // Checkbox button
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        checkboxButton.layer.cornerRadius = 20
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        addSubview(checkboxButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Gradient background
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Icon container
            iconContainer.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.medium),
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            // Progress indicator
            progressIndicator.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.medium),
            progressIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            progressIndicator.widthAnchor.constraint(equalToConstant: 60),
            progressIndicator.heightAnchor.constraint(equalToConstant: 60),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: Spacing.medium),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            titleLabel.trailingAnchor.constraint(equalTo: progressIndicator.leadingAnchor, constant: -Spacing.small),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.micro),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            descriptionLabel.trailingAnchor.constraint(equalTo: progressIndicator.leadingAnchor, constant: -Spacing.small),
            
            // Streak container
            streakContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.medium),
            streakContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            streakContainer.widthAnchor.constraint(equalToConstant: 80),
            streakContainer.heightAnchor.constraint(equalToConstant: 24),
            
            // Streak label
            streakLabel.centerXAnchor.constraint(equalTo: streakContainer.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: streakContainer.centerYAnchor),
            
            // Checkbox button
            checkboxButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.medium),
            checkboxButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            checkboxButton.widthAnchor.constraint(equalToConstant: 40),
            checkboxButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupInteractions() {
        // Add swipe gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        addGestureRecognizer(rightSwipe)
        
        // Add tap gesture for card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
        
        // Prepare haptic feedback
        hapticFeedback.prepare()
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = [.button]
        
        // Checkbox button accessibility
        checkboxButton.isAccessibilityElement = true
        checkboxButton.accessibilityTraits = [.button]
        checkboxButton.accessibilityLabel = "Complete habit"
    }
    
    // MARK: - Public Methods
    
    func configure(with habit: Habit) {
        self.habit = habit
        
        // Set basic content
        titleLabel.text = habit.title
        descriptionLabel.text = habit.description?.isEmpty == false ? habit.description : "Daily habit"
        iconImageView.image = UIImage(systemName: habit.icon)
        
        // Configure gradient based on habit color
        setupGradientBackground(for: habit)
        
        // Configure progress
        updateProgress(for: habit)
        
        // Configure streak
        updateStreak(for: habit)
        
        // Configure completion state
        updateCompletionState(for: habit)
        
        // Update accessibility
        updateAccessibility(for: habit)
    }
    
    private func setupGradientBackground(for habit: Habit) {
        // Remove existing gradient
        gradientLayer?.removeFromSuperlayer()
        
        // Create new gradient based on habit color
        let primaryColor = ColorHelper.color(fromHex: habit.color)
        //Please provide the code to darken the color here
        let secondaryColor = primaryColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = bounds
        gradientLayer?.colors = [primaryColor.cgColor, secondaryColor.cgColor]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer?.cornerRadius = CornerRadius.Component.card
        
        gradientView.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    private func updateProgress(for habit: Habit) {
        let isCompleted = habit.isCompletedToday()
        let progress: CGFloat = isCompleted ? 1.0 : 0.0
        
        progressIndicator.setProgress(progress, animated: true)
        
        // Add completion animation if needed
        if isCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            }
        }
    }
    
    private func updateStreak(for habit: Habit) {
        if habit.streak > 0 {
            streakLabel.text = "🔥 \(habit.streak)"
        } else {
            streakLabel.text = "0 days"
        }
    }
    
    private func updateCompletionState(for habit: Habit) {
        let isCompleted = habit.isCompletedToday()
        
        let iconName = isCompleted ? "checkmark.circle.fill" : "circle"
        let iconColor = isCompleted ? UIColor.systemGreen : UIColor.white.withAlphaComponent(0.7)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        checkboxButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        checkboxButton.tintColor = iconColor
        
        // Update button accessibility
        checkboxButton.accessibilityLabel = isCompleted ? "Mark as incomplete" : "Mark as complete"
    }
    
    private func updateAccessibility(for habit: Habit) {
        let isCompleted = habit.isCompletedToday()
        let streakText = habit.streak > 0 ? ", \(habit.streak) day streak" : ""
        let statusText = isCompleted ? "completed" : "not completed"
        
        accessibilityLabel = "\(habit.title), \(statusText)\(streakText)"
        accessibilityHint = "Double tap to view details, swipe to toggle completion"
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    // MARK: - Interactions
    
    @objc private func cardTapped() {
        // Spring animation for tap feedback
        animateSpring(duration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        } completion: { _ in
            self.animateSpring(duration: 0.2) {
                self.transform = .identity
            }
        }
        
        hapticFeedback.impactOccurred()
        
        // Navigate to detail view or complete habit based on state
        guard let habit = habit else { return }
        
        if !habit.isCompletedToday() {
            completeHabit()
        } else {
            // Show detail view (you can implement this)
            print("Show habit detail for: \(habit.title)")
        }
    }
    
    @objc private func checkboxTapped() {
        guard let habit = habit else { return }
        
        // Animate checkbox
        checkboxButton.animateSpring(duration: 0.1) {
            self.checkboxButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            self.checkboxButton.animateSpring(duration: 0.1) {
                self.checkboxButton.transform = .identity
            }
        }
        
        hapticFeedback.impactOccurred()
        
        if !habit.isCompletedToday() {
            completeHabit()
        } else {
            // Handle uncomplete if needed
            uncompleteHabit()
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let habit = habit else { return }
        
        // Animate swipe feedback
        let direction: CGFloat = gesture.direction == .left ? -20 : 20
        
        animateSpring(duration: 0.3) {
            self.transform = CGAffineTransform(translationX: direction, y: 0)
        } completion: { _ in
            self.animateSpring(duration: 0.3) {
                self.transform = .identity
            }
        }
        
        hapticFeedback.impactOccurred()
        
        // Toggle completion on swipe
        if !habit.isCompletedToday() {
            completeHabit()
        } else {
            uncompleteHabit()
        }
    }
    
    private func completeHabit() {
        guard let habit = habit else { return }
        delegate?.didTapCompleteButton(for: habit)
        
        // Animate completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateCompletionState(for: habit)
            self.updateProgress(for: habit)
        }
    }
    
    private func uncompleteHabit() {
        guard let habit = habit else { return }
        // Implement uncomplete functionality if needed
        print("Uncomplete habit: \(habit.title)")
    }
}

// MARK: - Gradient Variants

extension HabitCardView {
    
    /// Apply predefined gradient styles
    func applyGradientStyle(_ style: HabitGradientStyle) {
        gradientLayer?.removeFromSuperlayer()
        
        let colors: [CGColor]
        switch style {
        case .fitness:
            colors = [UIColor.systemGreen.cgColor, UIColor.systemTeal.cgColor]
        case .mindfulness:
            colors = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
        case .productivity:
            colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        case .learning:
            colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
        case .health:
            colors = [UIColor.systemPink.cgColor, UIColor.systemRed.cgColor]
        case .custom(let color):
            //Please provide the code to darken the color here
            colors = [color.cgColor, color.cgColor]
        }
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = bounds
        gradientLayer?.colors = colors
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer?.cornerRadius = CornerRadius.Component.card
        
        gradientView.layer.insertSublayer(gradientLayer!, at: 0)
    }
}

// MARK: - Gradient Style Enum

enum HabitGradientStyle {
    case fitness
    case mindfulness
    case productivity
    case learning
    case health
    case custom(UIColor)
}

// MARK: - Delegate Protocol

protocol HabitCardViewDelegate: AnyObject {
    func didTapCompleteButton(for habit: Habit)
}
