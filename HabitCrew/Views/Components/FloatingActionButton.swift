//
//  FloatingActionButton.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  FloatingActionButton.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Floating Action Button - Modern gradient FAB for adding habits
//

import UIKit

/// Modern floating action button with gradient background and smooth animations
class FloatingActionButton: UIButton {
    
    // MARK: - Properties
    
    private var gradientLayer: CAGradientLayer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var gradientColors: [UIColor] = [.accentMint, .accentPurple] {
        didSet { updateGradient() }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Setup
    
    private func setupButton() {
        setupAppearance()
        setupInteractions()
        setupAccessibility()
    }
    
    private func setupAppearance() {
        // Basic styling
        tintColor = .white
        applyCornerRadius(.circular)
        applyShadow(.standard)
        
        // Icon configuration
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        
        // Set initial size
        setSize(width: 60, height: 60)
        
        // Setup gradient
        updateGradient()
    }
    
    private func setupInteractions() {
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        hapticFeedback.prepare()
    }
    
    private func setupAccessibility() {
        accessibilityLabel = "Add new habit"
        accessibilityHint = "Double tap to create a new habit"
        accessibilityTraits = [.button]
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame
        gradientLayer?.frame = bounds
        
        // Ensure circular shape
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        gradientLayer?.cornerRadius = layer.cornerRadius
    }
    
    // MARK: - Gradient
    
    private func updateGradient() {
        gradientLayer?.removeFromSuperlayer()
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = bounds
        gradientLayer?.colors = gradientColors.map { $0.cgColor }
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer?.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    // MARK: - Interactions
    
    @objc private func buttonTouchDown() {
        hapticFeedback.prepare()
        
        // Scale down animation
        animateSpring(duration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc private func buttonTouchUp() {
        hapticFeedback.impactOccurred()
        
        // Scale back up animation
        animateSpring(duration: 0.2, dampingRatio: 0.6) {
            self.transform = .identity
        }
    }
    
    // MARK: - Public Methods
    
    /// Animates the button into view
    func animateIn(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(
            withDuration: 0.8,
            delay: delay,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction],
            animations: {
                self.alpha = 1
                self.transform = .identity
            }
        )
    }
    
    /// Animates the button out of view
    func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    /// Pulse animation for attention
    func pulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 1.0
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.autoreverses = true
        pulse.repeatCount = 3
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(pulse, forKey: "pulse")
    }
    
    /// Rotation animation for state changes
    func rotateIcon(to iconName: String, animated: Bool = true) {
        let newImage = UIImage(systemName: iconName, withConfiguration: imageView?.preferredSymbolConfiguration)
        
        if animated {
            UIView.transition(
                with: self,
                duration: 0.3,
                options: [.transitionCrossDissolve],
                animations: {
                    self.setImage(newImage, for: .normal)
                }
            )
        } else {
            setImage(newImage, for: .normal)
        }
    }
}

// MARK: - Factory Methods

extension FloatingActionButton {
    
    /// Creates a primary FAB with mint-purple gradient
    static func primary() -> FloatingActionButton {
        let button = FloatingActionButton()
        button.gradientColors = [.accentMint, .accentPurple]
        return button
    }
    
    /// Creates a success FAB with green gradient
    static func success() -> FloatingActionButton {
        let button = FloatingActionButton()
        button.gradientColors = [.accentGreen, .accentMint]
        return button
    }
    
    /// Creates a warning FAB with orange-coral gradient
    static func warning() -> FloatingActionButton {
        let button = FloatingActionButton()
        button.gradientColors = [.accentOrange, .accentCoral]
        return button
    }
    
    /// Creates a custom gradient FAB
    static func custom(colors: [UIColor]) -> FloatingActionButton {
        let button = FloatingActionButton()
        button.gradientColors = colors
        return button
    }
}