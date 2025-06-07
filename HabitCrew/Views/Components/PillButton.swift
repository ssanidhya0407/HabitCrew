//
//  PillButton.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  PillButton.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Pill Button Component
//

import UIKit

/// Modern pill-shaped button with gradient support
/// Inspired by habit tracking app design patterns
class PillButton: UIButton {
    
    // MARK: - Button Style
    
    enum Style {
        case primary      // Mint gradient
        case secondary    // Purple gradient
        case destructive  // Coral solid
        case outline      // Transparent with border
        case ghost        // Text only
    }
    
    // MARK: - Properties
    
    private var buttonStyle: Style = .primary
    private var gradientLayer: CAGradientLayer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Initialization
    
    init(style: Style = .primary) {
        self.buttonStyle = style
        super.init(frame: .zero)
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
        // Apply corner radius
        applyCornerRadius(.button)
        
        // Set typography
        titleLabel?.font = .button
        
        // Configure for style
        applyStyle(buttonStyle)
        
        // Set content edge insets
        contentEdgeInsets = Spacing.Component.buttonPadding
        
        // Ensure minimum touch target
        let minHeight = Spacing.Layout.minTouchTarget
        heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
    }
    
    private func setupInteractions() {
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupAccessibility() {
        configureAccessibility(
            label: titleLabel?.text ?? "Button",
            traits: .button,
            isAccessible: true
        )
    }
    
    // MARK: - Style Application
    
    func applyStyle(_ style: Style) {
        self.buttonStyle = style
        
        switch style {
        case .primary:
            setupPrimaryStyle()
        case .secondary:
            setupSecondaryStyle()
        case .destructive:
            setupDestructiveStyle()
        case .outline:
            setupOutlineStyle()
        case .ghost:
            setupGhostStyle()
        }
    }
    
    private func setupPrimaryStyle() {
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.8), for: .highlighted)
        setTitleColor(.textDisabled, for: .disabled)
        
        // Will apply gradient in layoutSubviews
        backgroundColor = .accentMint
    }
    
    private func setupSecondaryStyle() {
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.8), for: .highlighted)
        setTitleColor(.textDisabled, for: .disabled)
        
        backgroundColor = .accentPurple
    }
    
    private func setupDestructiveStyle() {
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.8), for: .highlighted)
        setTitleColor(.textDisabled, for: .disabled)
        
        backgroundColor = .accentCoral
        applyShadow(.subtle)
    }
    
    private func setupOutlineStyle() {
        setTitleColor(.accentMint, for: .normal)
        setTitleColor(.accentMint.withAlphaComponent(0.8), for: .highlighted)
        setTitleColor(.textDisabled, for: .disabled)
        
        backgroundColor = .clear
        applyBorder(color: .accentMint, width: 2.0)
        applyShadow(.none)
    }
    
    private func setupGhostStyle() {
        setTitleColor(.accentMint, for: .normal)
        setTitleColor(.accentMint.withAlphaComponent(0.8), for: .highlighted)
        setTitleColor(.textDisabled, for: .disabled)
        
        backgroundColor = .clear
        removeBorder()
        applyShadow(.none)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply gradient for primary style
        if buttonStyle == .primary {
            applyGradient(.mintPurple)
        }
        
        // Update gradient layer frame if it exists
        gradientLayer?.frame = bounds
        gradientLayer?.cornerRadius = layer.cornerRadius
    }
    
    // MARK: - Interactions
    
    @objc private func buttonTouchDown() {
        hapticFeedback.prepare()
        
        animateSpring(duration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    @objc private func buttonTouchUp() {
        hapticFeedback.impactOccurred()
        
        animateSpring(duration: 0.2) {
            self.transform = .identity
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets button text with accessibility support
    func setText(_ text: String) {
        setTitle(text, for: .normal)
        accessibilityLabel = text
    }
    
    /// Sets loading state
    func setLoading(_ isLoading: Bool, loadingText: String = "Loading...") {
        if isLoading {
            isEnabled = false
            setTitle(loadingText, for: .normal)
            
            // Add loading indicator
            let activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()
            
            addSubview(activityIndicator)
            activityIndicator.centerInSuperview()
            
            titleLabel?.alpha = 0
        } else {
            isEnabled = true
            titleLabel?.alpha = 1
            
            // Remove loading indicator
            subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
        }
    }
    
    /// Adds icon to button
    func setIcon(_ image: UIImage?, position: IconPosition = .leading) {
        switch position {
        case .leading:
            setImage(image, for: .normal)
            semanticContentAttribute = .forceLeftToRight
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Spacing.small)
        case .trailing:
            setImage(image, for: .normal)
            semanticContentAttribute = .forceRightToLeft
            imageEdgeInsets = UIEdgeInsets(top: 0, left: Spacing.small, bottom: 0, right: 0)
        }
        
        // Ensure image is template rendered for proper coloring
        image?.withRenderingMode(.alwaysTemplate)
    }
    
    enum IconPosition {
        case leading
        case trailing
    }
}

// MARK: - Button Factory

extension PillButton {
    
    /// Creates primary action button
    static func primary(title: String) -> PillButton {
        let button = PillButton(style: .primary)
        button.setText(title)
        return button
    }
    
    /// Creates secondary action button
    static func secondary(title: String) -> PillButton {
        let button = PillButton(style: .secondary)
        button.setText(title)
        return button
    }
    
    /// Creates destructive action button
    static func destructive(title: String) -> PillButton {
        let button = PillButton(style: .destructive)
        button.setText(title)
        return button
    }
    
    /// Creates outline button
    static func outline(title: String) -> PillButton {
        let button = PillButton(style: .outline)
        button.setText(title)
        return button
    }
    
    /// Creates ghost button
    static func ghost(title: String) -> PillButton {
        let button = PillButton(style: .ghost)
        button.setText(title)
        return button
    }
}

// MARK: - Size Variants

class CompactPillButton: PillButton {
    
    override func setupAppearance() {
        super.setupAppearance()
        
        // Smaller content insets
        contentEdgeInsets = UIEdgeInsets(
            top: Spacing.small,
            left: Spacing.medium,
            bottom: Spacing.small,
            right: Spacing.medium
        )
        
        // Smaller font
        titleLabel?.font = .bodySmall
    }
}

class LargePillButton: PillButton {
    
    override func setupAppearance() {
        super.setupAppearance()
        
        // Larger content insets
        contentEdgeInsets = UIEdgeInsets(
            top: Spacing.large,
            left: Spacing.xLarge,
            bottom: Spacing.large,
            right: Spacing.xLarge
        )
        
        // Larger font
        titleLabel?.font = .headline
    }
}