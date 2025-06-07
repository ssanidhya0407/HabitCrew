//
//  CAGradientLayer+Accents.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//

//
//  CAGradientLayer+Accents.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Gradient Extensions
//

import UIKit

// MARK: - CAGradientLayer Extensions

extension CAGradientLayer {
    
    // MARK: - Design System Gradients
    
    /// Creates mint to purple gradient
    static func mintPurpleGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = DesignTokens.Gradients.mintPurple
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    /// Creates purple to coral gradient
    static func purpleCoralGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = DesignTokens.Gradients.purpleCoral
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    /// Creates success gradient
    static func successGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = DesignTokens.Gradients.success
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    // MARK: - Gradient Configurations
    
    /// Applies design system gradient configuration
    func applyGradientStyle(_ style: GradientConfiguration) {
        colors = style.colors
        startPoint = style.startPoint
        endPoint = style.endPoint
        locations = style.locations
    }
    
    /// Creates a radial-like gradient effect
    static func radialGradient(colors: [CGColor], center: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = colors
        gradient.type = .radial
        gradient.startPoint = center
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    /// Creates an animated gradient
    func animateGradient(to newColors: [CGColor], duration: TimeInterval = 0.3) {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = colors
        animation.toValue = newColors
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        add(animation, forKey: "colorChange")
        colors = newColors
    }
}

// MARK: - Gradient Configuration

struct GradientConfiguration {
    let colors: [CGColor]
    let startPoint: CGPoint
    let endPoint: CGPoint
    let locations: [NSNumber]?
    
    init(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1), locations: [NSNumber]? = nil) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations
    }
}

// MARK: - Predefined Gradient Configurations

extension GradientConfiguration {
    
    /// Mint to purple diagonal gradient
    static let mintPurple = GradientConfiguration(
        colors: DesignTokens.Gradients.mintPurple,
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 1)
    )
    
    /// Purple to coral diagonal gradient
    static let purpleCoral = GradientConfiguration(
        colors: DesignTokens.Gradients.purpleCoral,
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 1)
    )
    
    /// Success gradient
    static let success = GradientConfiguration(
        colors: DesignTokens.Gradients.success,
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 0)
    )
    
    /// Vertical mint gradient
    static let verticalMint = GradientConfiguration(
        colors: [
            DesignTokens.Accent.mint.cgColor,
            DesignTokens.Accent.mint.withAlphaComponent(0.7).cgColor
        ],
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 0, y: 1)
    )
    
    /// Horizontal purple gradient
    static let horizontalPurple = GradientConfiguration(
        colors: [
            DesignTokens.Accent.purple.cgColor,
            DesignTokens.Accent.purple.withAlphaComponent(0.7).cgColor
        ],
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 1, y: 0)
    )
    
    /// Subtle background gradient
    static let subtleBackground = GradientConfiguration(
        colors: [
            DesignTokens.Background.primary.cgColor,
            DesignTokens.Background.secondary.cgColor
        ],
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 0, y: 1)
    )
}

// MARK: - Gradient Button Helper

extension UIButton {
    
    /// Adds gradient background to button
    func addGradientBackground(_ configuration: GradientConfiguration) {
        // Remove existing gradient layers
        layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.applyGradientStyle(configuration)
        gradientLayer.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// Updates gradient frame when button frame changes
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient layer frame
        layer.sublayers?.forEach { sublayer in
            if let gradientLayer = sublayer as? CAGradientLayer {
                gradientLayer.frame = bounds
                gradientLayer.cornerRadius = layer.cornerRadius
            }
        }
    }
}

// MARK: - Gradient Cache for Performance

class GradientCache {
    static let shared = GradientCache()
    private var cache: [String: CAGradientLayer] = [:]
    
    private init() {}
    
    /// Returns cached gradient or creates new one
    func gradient(for configuration: GradientConfiguration, size: CGSize) -> CAGradientLayer {
        let key = "\(configuration.colors.count)-\(size.width)x\(size.height)"
        
        if let cachedGradient = cache[key] {
            return cachedGradient
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.applyGradientStyle(configuration)
        
        cache[key] = gradient
        return gradient
    }
    
    /// Clears the gradient cache
    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Progress Gradient

extension CAGradientLayer {
    
    /// Creates a progress gradient that fills from left to right
    static func progressGradient(progress: CGFloat, activeColors: [CGColor], inactiveColor: CGColor) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        let clampedProgress = max(0, min(1, progress))
        
        if clampedProgress == 0 {
            gradient.colors = [inactiveColor, inactiveColor]
        } else if clampedProgress == 1 {
            gradient.colors = activeColors
        } else {
            gradient.colors = activeColors + [inactiveColor]
            gradient.locations = [0, NSNumber(value: clampedProgress), NSNumber(value: clampedProgress)]
        }
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        return gradient
    }
}
