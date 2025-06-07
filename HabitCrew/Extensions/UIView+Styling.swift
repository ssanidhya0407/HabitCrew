//
//  UIView+Styling.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//

//
//  UIView+Styling.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - View Styling Extensions
//

import UIKit

// MARK: - View Styling Extensions

extension UIView {
    
    // MARK: - Corner Radius
    
    /// Applies design system corner radius
    func applyCornerRadius(_ radius: CornerRadiusStyle) {
        switch radius {
        case .none:
            layer.cornerRadius = CornerRadius.none
        case .small:
            layer.cornerRadius = CornerRadius.small
        case .medium:
            layer.cornerRadius = CornerRadius.medium
        case .large:
            layer.cornerRadius = CornerRadius.large
        case .xLarge:
            layer.cornerRadius = CornerRadius.xLarge
        case .xxLarge:
            layer.cornerRadius = CornerRadius.xxLarge
        case .card:
            layer.cornerRadius = CornerRadius.Component.card
        case .button:
            layer.cornerRadius = CornerRadius.Component.button
        case .input:
            layer.cornerRadius = CornerRadius.Component.input
        case .circular:
            makeCircular()
        case .custom(let value):
            layer.cornerRadius = value
        }
        layer.masksToBounds = true
    }
    
    // MARK: - Shadow
    
    /// Applies design system shadow
    func applyShadow(_ shadowStyle: ShadowStyle) {
        layer.masksToBounds = false
        
        let config: ShadowConfiguration
        switch shadowStyle {
        case .none:
            layer.shadowOpacity = 0
            return
        case .subtle:
            config = CornerRadius.Shadow.subtle
        case .standard:
            config = CornerRadius.Shadow.standard
        case .deep:
            config = CornerRadius.Shadow.deep
        case .custom(let customConfig):
            config = customConfig
        }
        
        layer.shadowColor = config.color.cgColor
        layer.shadowOffset = config.offset
        layer.shadowRadius = config.radius
        layer.shadowOpacity = config.opacity
    }
    
    /// Applies both corner radius and shadow (for cards and elevated elements)
    func applyCardStyling(cornerRadius: CornerRadiusStyle = .card, shadow: ShadowStyle = .standard) {
        applyCornerRadius(cornerRadius)
        applyShadow(shadow)
    }
    
    // MARK: - Background
    
    /// Applies design system background color
    func applyBackground(_ backgroundStyle: BackgroundStyle) {
        switch backgroundStyle {
        case .primary:
            backgroundColor = .backgroundPrimary
        case .secondary:
            backgroundColor = .backgroundSecondary
        case .elevated:
            backgroundColor = .backgroundElevated
        case .clear:
            backgroundColor = .clear
        case .custom(let color):
            backgroundColor = color
        }
    }
    
    // MARK: - Border
    
    /// Applies design system border
    func applyBorder(color: UIColor = .border, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    /// Removes border
    func removeBorder() {
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Gradient Background
    
    /// Applies gradient background
    func applyGradient(_ gradientStyle: GradientStyle) {
        // Remove existing gradient layers
        layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        switch gradientStyle {
        case .mintPurple:
            gradientLayer.colors = DesignTokens.Gradients.mintPurple
        case .purpleCoral:
            gradientLayer.colors = DesignTokens.Gradients.purpleCoral
        case .success:
            gradientLayer.colors = DesignTokens.Gradients.success
        case .custom(let colors):
            gradientLayer.colors = colors
        }
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Animation Helpers
    
    /// Animates view with spring animation
    func animateSpring(
        duration: TimeInterval = 0.3,
        dampingRatio: CGFloat = 0.7,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction, .curveEaseInOut],
            animations: animations,
            completion: completion
        )
    }
    
    /// Pulse animation for user feedback
    func pulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 1.0
        pulse.toValue = 0.95
        pulse.autoreverses = true
        pulse.repeatCount = 1
        layer.add(pulse, forKey: "pulse")
    }
    
    /// Shake animation for error feedback
    func shakeAnimation() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))
        layer.add(shake, forKey: "shake")
    }
}

// MARK: - Style Enums

enum CornerRadiusStyle {
    case none
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    case card
    case button
    case input
    case circular
    case custom(CGFloat)
}

enum ShadowStyle {
    case none
    case subtle
    case standard
    case deep
    case custom(ShadowConfiguration)
}

enum BackgroundStyle {
    case primary
    case secondary
    case elevated
    case clear
    case custom(UIColor)
}

enum GradientStyle {
    case mintPurple
    case purpleCoral
    case success
    case custom([CGColor])
}

// MARK: - Layout Helpers

extension UIView {
    
    /// Adds multiple subviews at once
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    /// Constrains view to superview with insets
    func constrainToSuperview(with insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
    
    /// Constrains view to safe area with insets
    func constrainToSafeArea(with insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
                leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
                trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
                bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
            ])
        } else {
            constrainToSuperview(with: insets)
        }
    }
    
    /// Centers view in superview
    func centerInSuperview() {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
    /// Sets fixed size constraints
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    /// Sets aspect ratio constraint
    func setAspectRatio(_ ratio: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio).isActive = true
    }
}

// MARK: - Accessibility Helpers

extension UIView {
    
    /// Configures accessibility properties
    func configureAccessibility(
        label: String? = nil,
        hint: String? = nil,
        traits: UIAccessibilityTraits = .none,
        isAccessible: Bool = true
    ) {
        self.isAccessibilityElement = isAccessible
        self.accessibilityLabel = label
        self.accessibilityHint = hint
        self.accessibilityTraits = traits
    }
}
