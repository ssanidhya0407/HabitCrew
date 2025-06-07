//
//  UIColor+DesignSystem.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//

//
//  UIColor+DesignSystem.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Color Extensions
//

import UIKit

// MARK: - Design System Color Extensions

extension UIColor {
    
    // MARK: - Background Colors
    
    /// Primary dark background - #1C1C1E
    static var backgroundPrimary: UIColor {
        return DesignTokens.Background.primary
    }
    
    /// Secondary card background - #2C2C2E
    static var backgroundSecondary: UIColor {
        return DesignTokens.Background.secondary
    }
    
    /// Elevated surface background
    static var backgroundElevated: UIColor {
        return DesignTokens.Background.elevated
    }
    
    // MARK: - Accent Colors
    
    /// Mint accent color - #64FFDA
    static var accentMint: UIColor {
        return DesignTokens.Accent.mint
    }
    
    /// Purple accent color - #BB86FC
    static var accentPurple: UIColor {
        return DesignTokens.Accent.purple
    }
    
    /// Coral accent color - #FF6B6B
    static var accentCoral: UIColor {
        return DesignTokens.Accent.coral
    }
    
    /// Success green - #30D158
    static var accentGreen: UIColor {
        return DesignTokens.Accent.green
    }
    
    /// Warning orange - #FF9F0A
    static var accentOrange: UIColor {
        return DesignTokens.Accent.orange
    }
    
    // MARK: - Text Colors
    
    /// Primary text color - White
    static var textPrimary: UIColor {
        return DesignTokens.Text.primary
    }
    
    /// Secondary text color - #8E8E93
    static var textSecondary: UIColor {
        return DesignTokens.Text.secondary
    }
    
    /// Tertiary text color
    static var textTertiary: UIColor {
        return DesignTokens.Text.tertiary
    }
    
    /// Disabled text color
    static var textDisabled: UIColor {
        return DesignTokens.Text.disabled
    }
    
    // MARK: - Semantic Colors
    
    /// Button primary color
    static var buttonPrimary: UIColor {
        return DesignTokens.Semantic.buttonPrimary
    }
    
    /// Button secondary color
    static var buttonSecondary: UIColor {
        return DesignTokens.Semantic.buttonSecondary
    }
    
    /// Button destructive color
    static var buttonDestructive: UIColor {
        return DesignTokens.Semantic.buttonDestructive
    }
    
    /// Border color
    static var border: UIColor {
        return DesignTokens.Semantic.border
    }
    
    /// Divider color
    static var divider: UIColor {
        return DesignTokens.Semantic.divider
    }
    
    // MARK: - System Colors
    
    /// Success state color
    static var systemSuccess: UIColor {
        return DesignTokens.System.success
    }
    
    /// Warning state color
    static var systemWarning: UIColor {
        return DesignTokens.System.warning
    }
    
    /// Error state color
    static var systemError: UIColor {
        return DesignTokens.System.error
    }
    
    /// Info state color
    static var systemInfo: UIColor {
        return DesignTokens.System.info
    }
}

// MARK: - Color Utilities

extension UIColor {
    
    /// Creates a color from hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    /// Returns hex string representation of the color
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage))
    }
    
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    /// Adjusts the brightness of the color
    private func adjust(by percentage: CGFloat = 30.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                          green: min(green + percentage/100, 1.0),
                          blue: min(blue + percentage/100, 1.0),
                          alpha: alpha)
        } else {
            return self
        }
    }
    
    /// Returns the contrasting color (black or white) for better readability
    var contrastingColor: UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate luminance using standard formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        return luminance > 0.5 ? .black : .white
    }
}

// MARK: - Dynamic Color Support

@available(iOS 13.0, *)
extension UIColor {
    
    /// Creates a dynamic color that adapts to light/dark mode
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
    
    /// Design system colors with future light mode support
    struct Adaptive {
        /// Adaptive background colors
        static var backgroundPrimary: UIColor {
            return dynamicColor(light: .systemBackground, dark: DesignTokens.Background.primary)
        }
        
        static var backgroundSecondary: UIColor {
            return dynamicColor(light: .secondarySystemBackground, dark: DesignTokens.Background.secondary)
        }
        
        /// Adaptive text colors
        static var textPrimary: UIColor {
            return dynamicColor(light: .label, dark: DesignTokens.Text.primary)
        }
        
        static var textSecondary: UIColor {
            return dynamicColor(light: .secondaryLabel, dark: DesignTokens.Text.secondary)
        }
    }
}
