//
//  UIFont+Typography.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//

//
//  UIFont+Typography.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Typography Extensions
//

import UIKit

// MARK: - Typography Extensions

extension UIFont {
    
    // MARK: - Design System Typography
    
    /// Display font - SF Pro Display, 32pt, Bold
    static var display: UIFont {
        return Typography.display
    }
    
    /// Headline font - SF Pro Display, 24pt, Semibold
    static var headline: UIFont {
        return Typography.headline
    }
    
    /// Title font - SF Pro Text, 20pt, Semibold
    static var title: UIFont {
        return Typography.title
    }
    
    /// Body font - SF Pro Text, 16pt, Regular
    static var body: UIFont {
        return Typography.body
    }
    
    /// Caption font - SF Pro Text, 12pt, Medium
    static var caption: UIFont {
        return Typography.caption
    }
    
    /// Large body font - SF Pro Text, 18pt, Regular
    static var bodyLarge: UIFont {
        return Typography.bodyLarge
    }
    
    /// Small body font - SF Pro Text, 14pt, Regular
    static var bodySmall: UIFont {
        return Typography.bodySmall
    }
    
    /// Button font - SF Pro Text, 16pt, Semibold
    static var button: UIFont {
        return Typography.button
    }
    
    /// Tab bar font - SF Pro Text, 10pt, Medium
    static var tabBar: UIFont {
        return Typography.tabBar
    }
    
    // MARK: - Accessible Typography
    
    /// Typography with Dynamic Type support
    struct Accessible {
        static var display: UIFont {
            return Typography.Accessible.display
        }
        
        static var headline: UIFont {
            return Typography.Accessible.headline
        }
        
        static var title: UIFont {
            return Typography.Accessible.title
        }
        
        static var body: UIFont {
            return Typography.Accessible.body
        }
        
        static var caption: UIFont {
            return Typography.Accessible.caption
        }
    }
}

// MARK: - UILabel Extensions

extension UILabel {
    
    /// Applies design system typography style
    func applyTypography(_ style: TypographyStyle) {
        switch style {
        case .display:
            font = .display
            textColor = .textPrimary
        case .headline:
            font = .headline
            textColor = .textPrimary
        case .title:
            font = .title
            textColor = .textPrimary
        case .body:
            font = .body
            textColor = .textPrimary
        case .bodySecondary:
            font = .body
            textColor = .textSecondary
        case .caption:
            font = .caption
            textColor = .textSecondary
        case .button:
            font = .button
            textColor = .textPrimary
        }
    }
    
    /// Applies accessible typography with Dynamic Type
    func applyAccessibleTypography(_ style: TypographyStyle) {
        switch style {
        case .display:
            font = .Accessible.display
            textColor = .textPrimary
        case .headline:
            font = .Accessible.headline
            textColor = .textPrimary
        case .title:
            font = .Accessible.title
            textColor = .textPrimary
        case .body:
            font = .Accessible.body
            textColor = .textPrimary
        case .bodySecondary:
            font = .Accessible.body
            textColor = .textSecondary
        case .caption:
            font = .Accessible.caption
            textColor = .textSecondary
        case .button:
            font = .button
            textColor = .textPrimary
        }
        adjustsFontForContentSizeCategory = true
    }
}

// MARK: - Typography Style Enum

enum TypographyStyle {
    case display
    case headline
    case title
    case body
    case bodySecondary
    case caption
    case button
}

// MARK: - UITextView Extensions

extension UITextView {
    
    /// Applies design system typography style to text view
    func applyTypography(_ style: TypographyStyle) {
        switch style {
        case .display:
            font = .display
            textColor = .textPrimary
        case .headline:
            font = .headline
            textColor = .textPrimary
        case .title:
            font = .title
            textColor = .textPrimary
        case .body:
            font = .body
            textColor = .textPrimary
        case .bodySecondary:
            font = .body
            textColor = .textSecondary
        case .caption:
            font = .caption
            textColor = .textSecondary
        case .button:
            font = .button
            textColor = .textPrimary
        }
    }
}

// MARK: - NSAttributedString Extensions

extension NSAttributedString {
    
    /// Creates attributed string with design system typography
    convenience init(string: String, style: TypographyStyle) {
        let attributes = Typography.Attributes.attributesForStyle(style)
        self.init(string: string, attributes: attributes)
    }
}

// MARK: - Typography Attributes Helper

extension Typography.Attributes {
    
    /// Returns attributes for a given typography style
    static func attributesForStyle(_ style: TypographyStyle) -> [NSAttributedString.Key: Any] {
        switch style {
        case .display:
            return display
        case .headline:
            return headline
        case .title:
            return title
        case .body:
            return body
        case .bodySecondary:
            return bodySecondary
        case .caption:
            return caption
        case .button:
            return [
                .font: Typography.button,
                .foregroundColor: DesignTokens.Text.primary
            ]
        }
    }
}

// MARK: - Font Loading Verification

extension UIFont {
    
    /// Verifies if SF Pro fonts are available
    static func verifySFProFonts() -> Bool {
        let testFont = UIFont(name: "SFProText-Regular", size: 16)
        return testFont != nil
    }
    
    /// Lists all available fonts (useful for debugging)
    static func listAvailableFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  Font: \(name)")
            }
        }
    }
}
