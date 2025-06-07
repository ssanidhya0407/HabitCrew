//
//  CornerRadius.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  CornerRadius.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Corner Radius System
//

import UIKit

/// Consistent corner radius system for UI components
struct CornerRadius {
    
    // MARK: - Base Radius Values
    
    /// No radius - 0pt
    /// Used for: Sharp edges, dividers
    static let none: CGFloat = 0
    
    /// Small radius - 4pt
    /// Used for: Small buttons, badges
    static let small: CGFloat = 4
    
    /// Medium radius - 8pt
    /// Used for: Standard buttons, small cards
    static let medium: CGFloat = 8
    
    /// Large radius - 12pt
    /// Used for: Input fields, medium cards
    static let large: CGFloat = 12
    
    /// Extra large radius - 16pt
    /// Used for: Cards, major components
    static let xLarge: CGFloat = 16
    
    /// Extra extra large radius - 24pt
    /// Used for: Pill buttons, rounded elements
    static let xxLarge: CGFloat = 24
    
    /// Circular radius
    /// Used for: Profile images, round buttons
    static let circular: CGFloat = .greatestFiniteMagnitude
    
    // MARK: - Component-Specific Radius
    
    /// Pre-defined radius values for specific components
    struct Component {
        /// Card corner radius - 16pt
        static let card = xLarge
        
        /// Button corner radius - 24pt (pill-shaped)
        static let button = xxLarge
        
        /// Input field corner radius - 12pt
        static let input = large
        
        /// Modal corner radius - 16pt
        static let modal = xLarge
        
        /// Tab bar corner radius - 12pt
        static let tabBar = large
        
        /// Progress bar corner radius - 8pt
        static let progressBar = medium
        
        /// Badge corner radius - 4pt
        static let badge = small
    }
    
    // MARK: - Adaptive Radius
    
    /// Radius values that adapt based on component size
    struct Adaptive {
        /// Returns appropriate radius based on view height
        static func radius(for height: CGFloat) -> CGFloat {
            switch height {
            case 0..<20:
                return small
            case 20..<32:
                return medium
            case 32..<44:
                return large
            case 44..<60:
                return xLarge
            default:
                return xxLarge
            }
        }
        
        /// Returns circular radius for perfect circles
        static func circular(for size: CGFloat) -> CGFloat {
            return size / 2
        }
    }
}

// MARK: - CALayer Extensions

extension CALayer {
    /// Applies corner radius with optional masking
    func applyCornerRadius(_ radius: CGFloat, maskToBounds: Bool = true) {
        self.cornerRadius = radius
        self.masksToBounds = maskToBounds
    }
    
    /// Applies specific corners rounding
    @available(iOS 11.0, *)
    func applyCornerRadius(_ radius: CGFloat, corners: CACornerMask) {
        self.cornerRadius = radius
        self.maskedCorners = corners
        self.masksToBounds = true
    }
}

// MARK: - UIView Extensions

extension UIView {
    /// Applies corner radius to view
    func applyCornerRadius(_ radius: CGFloat) {
        self.layer.applyCornerRadius(radius)
    }
    
    /// Applies specific corners rounding
    @available(iOS 11.0, *)
    func applyCornerRadius(_ radius: CGFloat, corners: CACornerMask) {
        self.layer.applyCornerRadius(radius, corners: corners)
    }
    
    /// Makes the view circular
    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.layer.masksToBounds = true
    }
}

// MARK: - Shadow and Corner Radius Combination

extension CornerRadius {
    /// Shadow configurations that work well with corner radius
    struct Shadow {
        /// Standard shadow with corner radius
        static let standard = ShadowConfiguration(
            color: UIColor.black.withAlphaComponent(0.15),
            offset: CGSize(width: 0, height: 4),
            radius: 20,
            opacity: 1.0
        )
        
        /// Subtle shadow for elevated elements
        static let subtle = ShadowConfiguration(
            color: UIColor.black.withAlphaComponent(0.08),
            offset: CGSize(width: 0, height: 2),
            radius: 8,
            opacity: 1.0
        )
        
        /// Deep shadow for modals and overlays
        static let deep = ShadowConfiguration(
            color: UIColor.black.withAlphaComponent(0.25),
            offset: CGSize(width: 0, height: 8),
            radius: 32,
            opacity: 1.0
        )
    }
}

/// Configuration structure for shadows
struct ShadowConfiguration {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}