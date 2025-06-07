//
//  DesignTokens.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  DesignTokens.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Color Palette
//

import UIKit

/// Centralized design tokens for the HabitCrew app
/// Inspired by modern habit tracking apps with dark theme and vibrant accents
struct DesignTokens {
    
    // MARK: - Color Palette
    
    /// Primary background colors for dark theme
    struct Background {
        /// Main background color - #1C1C1E
        static let primary = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        
        /// Card background color - #2C2C2E
        static let secondary = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)
        
        /// Elevated surface color for modals and overlays
        static let elevated = UIColor(red: 0.22, green: 0.22, blue: 0.23, alpha: 1.0)
    }
    
    /// Vibrant accent colors for actions and highlights
    struct Accent {
        /// Primary action color - Mint #64FFDA
        static let mint = UIColor(red: 0.39, green: 1.0, blue: 0.85, alpha: 1.0)
        
        /// Secondary action color - Purple #BB86FC
        static let purple = UIColor(red: 0.73, green: 0.53, blue: 0.99, alpha: 1.0)
        
        /// Warning/streak color - Coral #FF6B6B
        static let coral = UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)
        
        /// Success color - Green #30D158
        static let green = UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0)
        
        /// Warning color - Orange #FF9F0A
        static let orange = UIColor(red: 1.0, green: 0.62, blue: 0.04, alpha: 1.0)
    }
    
    /// Text colors for optimal contrast and readability
    struct Text {
        /// Primary text color - White #FFFFFF
        static let primary = UIColor.white
        
        /// Secondary text color - Gray #8E8E93
        static let secondary = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
        
        /// Tertiary text color for subtle information
        static let tertiary = UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0)
        
        /// Disabled text color
        static let disabled = UIColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 1.0)
    }
    
    /// System colors for states and feedback
    struct System {
        static let success = Accent.green
        static let warning = Accent.orange
        static let error = Accent.coral
        static let info = Accent.purple
    }
    
    // MARK: - Gradient Definitions
    
    /// Pre-defined gradients for consistent visual appeal
    struct Gradients {
        /// Mint to Purple gradient for primary actions
        static let mintPurple = [Accent.mint.cgColor, Accent.purple.cgColor]
        
        /// Purple to Coral gradient for secondary actions
        static let purpleCoral = [Accent.purple.cgColor, Accent.coral.cgColor]
        
        /// Success gradient
        static let success = [Accent.green.cgColor, UIColor(red: 0.15, green: 0.68, blue: 0.28, alpha: 1.0).cgColor]
    }
}

// MARK: - Semantic Color Extensions

extension DesignTokens {
    /// Semantic colors that adapt to different contexts
    struct Semantic {
        // MARK: - Interactive Elements
        static let buttonPrimary = Accent.mint
        static let buttonSecondary = Accent.purple
        static let buttonDestructive = Accent.coral
        
        // MARK: - Surfaces
        static let cardBackground = Background.secondary
        static let modalBackground = Background.elevated
        static let screenBackground = Background.primary
        
        // MARK: - Borders and Dividers
        static let border = UIColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 1.0)
        static let divider = UIColor(red: 0.28, green: 0.28, blue: 0.30, alpha: 1.0)
    }
}