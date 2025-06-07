//
//  Spacing.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  Spacing.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Spacing System
//

import UIKit

/// Consistent spacing system for layouts and components
struct Spacing {
    
    // MARK: - Base Spacing Values
    
    /// Micro spacing - 4pt
    /// Used for: Icon padding, small element gaps
    static let micro: CGFloat = 4
    
    /// Small spacing - 8pt
    /// Used for: Text line spacing, button padding
    static let small: CGFloat = 8
    
    /// Medium spacing - 16pt
    /// Used for: Component margins, section padding
    static let medium: CGFloat = 16
    
    /// Large spacing - 24pt
    /// Used for: Screen margins, major component gaps
    static let large: CGFloat = 24
    
    /// Extra large spacing - 32pt
    /// Used for: Section breaks, major layout spacing
    static let xLarge: CGFloat = 32
    
    /// Extra extra large spacing - 48pt
    /// Used for: Screen sections, major visual breaks
    static let xxLarge: CGFloat = 48
    
    // MARK: - Semantic Spacing
    
    /// Component-specific spacing values
    struct Component {
        /// Button internal padding
        static let buttonPadding = UIEdgeInsets(
            top: medium,
            left: large,
            bottom: medium,
            right: large
        )
        
        /// Card internal padding
        static let cardPadding = UIEdgeInsets(
            top: medium,
            left: medium,
            bottom: medium,
            right: medium
        )
        
        /// Screen edge margins
        static let screenMargins = UIEdgeInsets(
            top: large,
            left: medium,
            bottom: large,
            right: medium
        )
        
        /// Text field padding
        static let textFieldPadding = UIEdgeInsets(
            top: medium,
            left: medium,
            bottom: medium,
            right: medium
        )
    }
    
    // MARK: - Layout Spacing
    
    /// Common layout spacing patterns
    struct Layout {
        /// Spacing between sections
        static let sectionSpacing = large
        
        /// Spacing between elements in a group
        static let groupSpacing = medium
        
        /// Spacing between related items
        static let itemSpacing = small
        
        /// Minimum touch target size (44pt Apple recommendation)
        static let minTouchTarget: CGFloat = 44
        
        /// Safe area insets for custom layouts
        static func safeAreaInsets(for view: UIView) -> UIEdgeInsets {
            if #available(iOS 11.0, *) {
                return view.safeAreaInsets
            } else {
                return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    // MARK: - Grid System
    
    /// Grid-based spacing for consistent layouts
    struct Grid {
        /// Base grid unit - 8pt
        private static let baseUnit: CGFloat = 8
        
        /// Returns spacing based on grid units
        static func unit(_ multiplier: Int) -> CGFloat {
            return baseUnit * CGFloat(multiplier)
        }
        
        /// Common grid spacing shortcuts
        static let halfUnit = unit(1) // 4pt
        static let oneUnit = unit(1)  // 8pt
        static let twoUnits = unit(2) // 16pt
        static let threeUnits = unit(3) // 24pt
        static let fourUnits = unit(4) // 32pt
        static let sixUnits = unit(6) // 48pt
    }
}

// MARK: - UIEdgeInsets Extensions

extension UIEdgeInsets {
    /// Creates uniform insets with the same value for all edges
    static func uniform(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
    /// Creates horizontal insets (left and right only)
    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }
    
    /// Creates vertical insets (top and bottom only)
    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: 0, bottom: value, right: 0)
    }
}

// MARK: - Auto Layout Helpers

extension Spacing {
    /// Convenience methods for Auto Layout constraints
    struct Constraint {
        /// Standard constraint priority values
        static let high = UILayoutPriority(750)
        static let medium = UILayoutPriority(500)
        static let low = UILayoutPriority(250)
        
        /// Creates a constraint with standard spacing
        static func spacing(_ spacing: CGFloat, priority: UILayoutPriority = .required) -> CGFloat {
            return spacing
        }
    }
}