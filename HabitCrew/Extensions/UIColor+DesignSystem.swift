//
//  UIColor+DesignSystem.swift
//  HabitCrew
//

import UIKit

extension UIColor {
    // MARK: - Background Colors
    static var backgroundPrimary: UIColor { return DesignTokens.Background.primary }
    static var backgroundSecondary: UIColor { return DesignTokens.Background.secondary }
    static var backgroundElevated: UIColor { return DesignTokens.Background.elevated }

    // MARK: - Accent Colors
    static var accentMint: UIColor { return DesignTokens.Accent.mint }
    static var accentPurple: UIColor { return DesignTokens.Accent.purple }
    static var accentCoral: UIColor { return DesignTokens.Accent.coral }
    static var accentGreen: UIColor { return DesignTokens.Accent.green }
    static var accentOrange: UIColor { return DesignTokens.Accent.orange }

    // MARK: - Text Colors
    static var textPrimary: UIColor { return DesignTokens.Text.primary }
    static var textSecondary: UIColor { return DesignTokens.Text.secondary }
    static var textTertiary: UIColor { return DesignTokens.Text.tertiary }
    static var textDisabled: UIColor { return DesignTokens.Text.disabled }

    // MARK: - Semantic Colors
    static var buttonPrimary: UIColor { return DesignTokens.Semantic.buttonPrimary }
    static var buttonSecondary: UIColor { return DesignTokens.Semantic.buttonSecondary }
    static var buttonDestructive: UIColor { return DesignTokens.Semantic.buttonDestructive }
    static var border: UIColor { return DesignTokens.Semantic.border }
    static var divider: UIColor { return DesignTokens.Semantic.divider }

    // MARK: - System Colors
    static var systemSuccess: UIColor { return DesignTokens.System.success }
    static var systemWarning: UIColor { return DesignTokens.System.warning }
    static var systemError: UIColor { return DesignTokens.System.error }
    static var systemInfo: UIColor { return DesignTokens.System.info }

    var contrastingColor: UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        return luminance > 0.5 ? .black : .white
    }
}
