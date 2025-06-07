//
//  Typography.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  Typography.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Typography Scale
//

import UIKit

/// Typography system for consistent text styling across the app
struct Typography {
    
    // MARK: - Font Families
    
    private enum FontFamily {
        static let display = "SFProDisplay"
        static let text = "SFProText"
        
        // Fallback to system fonts if SF Pro is not available
        static let displayFallback = UIFont.systemFont(ofSize: 32, weight: .bold)
        static let textFallback = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    // MARK: - Typography Scale
    
    /// Display text for hero sections and major headings
    /// SF Pro Display, 32pt, Bold
    static var display: UIFont {
        return UIFont(name: "\(FontFamily.display)-Bold", size: 32) ??
               UIFont.systemFont(ofSize: 32, weight: .bold)
    }
    
    /// Headlines for section titles and important content
    /// SF Pro Display, 24pt, Semibold
    static var headline: UIFont {
        return UIFont(name: "\(FontFamily.display)-Semibold", size: 24) ??
               UIFont.systemFont(ofSize: 24, weight: .semibold)
    }
    
    /// Titles for cards and content blocks
    /// SF Pro Text, 20pt, Semibold
    static var title: UIFont {
        return UIFont(name: "\(FontFamily.text)-Semibold", size: 20) ??
               UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    /// Body text for primary content
    /// SF Pro Text, 16pt, Regular
    static var body: UIFont {
        return UIFont(name: "\(FontFamily.text)-Regular", size: 16) ??
               UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    /// Caption text for secondary information
    /// SF Pro Text, 12pt, Medium
    static var caption: UIFont {
        return UIFont(name: "\(FontFamily.text)-Medium", size: 12) ??
               UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    // MARK: - Additional Text Styles
    
    /// Large body text for emphasized content
    static var bodyLarge: UIFont {
        return UIFont(name: "\(FontFamily.text)-Regular", size: 18) ??
               UIFont.systemFont(ofSize: 18, weight: .regular)
    }
    
    /// Small body text for compact layouts
    static var bodySmall: UIFont {
        return UIFont(name: "\(FontFamily.text)-Regular", size: 14) ??
               UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    /// Button text styling
    static var button: UIFont {
        return UIFont(name: "\(FontFamily.text)-Semibold", size: 16) ??
               UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    /// Tab bar text styling
    static var tabBar: UIFont {
        return UIFont(name: "\(FontFamily.text)-Medium", size: 10) ??
               UIFont.systemFont(ofSize: 10, weight: .medium)
    }
}

// MARK: - Dynamic Type Support

extension Typography {
    /// Returns scaled font based on user's accessibility settings
    static func scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle = .body) -> UIFont {
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        return fontMetrics.scaledFont(for: font)
    }
    
    /// Typography with Dynamic Type support
    struct Accessible {
        static var display: UIFont {
            return scaledFont(Typography.display, textStyle: .largeTitle)
        }
        
        static var headline: UIFont {
            return scaledFont(Typography.headline, textStyle: .title1)
        }
        
        static var title: UIFont {
            return scaledFont(Typography.title, textStyle: .title2)
        }
        
        static var body: UIFont {
            return scaledFont(Typography.body, textStyle: .body)
        }
        
        static var caption: UIFont {
            return scaledFont(Typography.caption, textStyle: .caption1)
        }
    }
}

// MARK: - Text Attributes

extension Typography {
    /// Pre-configured text attributes for common use cases
    struct Attributes {
        /// Display text attributes with primary color
        static var display: [NSAttributedString.Key: Any] {
            return [
                .font: Typography.display,
                .foregroundColor: DesignTokens.Text.primary
            ]
        }
        
        /// Headline text attributes with primary color
        static var headline: [NSAttributedString.Key: Any] {
            return [
                .font: Typography.headline,
                .foregroundColor: DesignTokens.Text.primary
            ]
        }
        
        /// Title text attributes with primary color
        static var title: [NSAttributedString.Key: Any] {
            return [
                .font: Typography.title,
                .foregroundColor: DesignTokens.Text.primary
            ]
        }
        
        /// Body text attributes with primary color
        static var body: [NSAttributedString.Key: Any] {
            return [
                .font: Typography.body,
                .foregroundColor: DesignTokens.Text.primary
            ]
        }
        
        /// Secondary body text attributes
        static var bodySecondary: [NSAttributedString.Key: Any] {
            return [
                .font: Typography.body,
                .foregroundColor: DesignTokens.Text.secondary
            ]
        }
        
        /// Caption text attributes with secondary color
        static var caption: [NSAttributedString.Key: Any] {
            return [
                .font: Typography.caption,
                .foregroundColor: DesignTokens.Text.secondary
            ]
        }
    }
}