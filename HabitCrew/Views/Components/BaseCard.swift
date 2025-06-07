//
//  BaseCard.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  BaseCard.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Base Card Component
//

import UIKit

/// Base card component with dark theme styling
/// Provides consistent card appearance across the app
class BaseCard: UIView {
    
    // MARK: - Properties
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.medium
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
    }
    
    // MARK: - Setup
    
    private func setupCard() {
        setupAppearance()
        setupLayout()
    }
    
    private func setupAppearance() {
        // Apply design system styling
        applyBackground(.secondary)
        applyCornerRadius(.card)
        applyShadow(.standard)
        
        // Configure accessibility
        configureAccessibility(
            label: "Card",
            traits: .none,
            isAccessible: true
        )
    }
    
    private func setupLayout() {
        addSubview(contentStackView)
        contentStackView.constrainToSuperview(with: Spacing.Component.cardPadding)
    }
    
    // MARK: - Public Methods
    
    /// Adds content view to the card
    func addContent(_ view: UIView) {
        contentStackView.addArrangedSubview(view)
    }
    
    /// Adds multiple content views to the card
    func addContent(_ views: [UIView]) {
        views.forEach { contentStackView.addArrangedSubview($0) }
    }
    
    /// Removes content view from the card
    func removeContent(_ view: UIView) {
        contentStackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    /// Clears all content from the card
    func clearContent() {
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    /// Sets spacing between content elements
    func setContentSpacing(_ spacing: CGFloat) {
        contentStackView.spacing = spacing
    }
    
    /// Sets content alignment
    func setContentAlignment(_ alignment: UIStackView.Alignment) {
        contentStackView.alignment = alignment
    }
    
    /// Animates card appearance
    func animateIn(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(
            withDuration: 0.6,
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
    
    /// Adds tap gesture with feedback
    func addTapGesture(target: Any?, action: Selector?) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        // Add visual feedback
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            animateSpring(duration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                self.alpha = 0.9
            }
        case .ended, .cancelled:
            animateSpring(duration: 0.2) {
                self.transform = .identity
                self.alpha = 1.0
            }
        default:
            break
        }
    }
}

// MARK: - Card Variants

/// Elevated card with stronger shadow
class ElevatedCard: BaseCard {
    
    override func setupAppearance() {
        super.setupAppearance()
        applyShadow(.deep)
        applyBackground(.elevated)
    }
}

/// Outlined card with border instead of shadow
class OutlinedCard: BaseCard {
    
    override func setupAppearance() {
        applyBackground(.secondary)
        applyCornerRadius(.card)
        applyBorder(color: .border, width: 1.0)
        applyShadow(.none)
        
        configureAccessibility(
            label: "Outlined Card",
            traits: .none,
            isAccessible: true
        )
    }
}

/// Gradient card with accent background
class GradientCard: BaseCard {
    
    private let gradientStyle: GradientStyle
    
    init(gradientStyle: GradientStyle = .mintPurple) {
        self.gradientStyle = gradientStyle
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        self.gradientStyle = .mintPurple
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(gradientStyle)
    }
    
    override func setupAppearance() {
        applyCornerRadius(.card)
        applyShadow(.standard)
        
        configureAccessibility(
            label: "Gradient Card",
            traits: .none,
            isAccessible: true
        )
    }
}