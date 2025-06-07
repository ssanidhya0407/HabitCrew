//
//  ModernTextField.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  ModernTextField.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Modern Text Field Component
//

import UIKit

/// Modern text field with floating labels and dark theme styling
class ModernTextField: UIView {
    
    // MARK: - Properties
    
    public let textField: UITextField = {
        let field = UITextField()
        field.font = .body
        field.textColor = .textPrimary
        field.tintColor = .accentMint
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.font = .caption
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .border
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let focusedUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .accentMint
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = CGAffineTransform(scaleX: 0, y: 1)
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption
        label.textColor = .systemError
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    private let assistiveLabel: UILabel = {
        let label = UILabel()
        label.font = .caption
        label.textColor = .textTertiary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var floatingLabelTopConstraint: NSLayoutConstraint!
    private var floatingLabelLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - State
    
    private var isFloating = false
    private var hasError = false
    
    // MARK: - Public Properties
    
    var text: String? {
        get { textField.text }
        set {
            textField.text = newValue
            updateFloatingLabel()
        }
    }
    
    var placeholder: String? {
        didSet {
            floatingLabel.text = placeholder
            textField.placeholder = isFloating ? nil : placeholder
        }
    }
    
    var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    var delegate: UITextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    // MARK: - Setup
    
    private func setupTextField() {
        setupLayout()
        setupAppearance()
        setupInteractions()
        setupAccessibility()
    }
    
    private func setupLayout() {
        addSubviews(textField, floatingLabel, underlineView, focusedUnderlineView, errorLabel, assistiveLabel)
        
        // Floating label constraints
        floatingLabelTopConstraint = floatingLabel.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.large)
        floatingLabelLeadingConstraint = floatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            // Floating label
            floatingLabelTopConstraint,
            floatingLabelLeadingConstraint,
            
            // Text field
            textField.topAnchor.constraint(equalTo: floatingLabel.bottomAnchor, constant: Spacing.micro),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Underline
            underlineView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Spacing.micro),
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            
            // Focused underline
            focusedUnderlineView.topAnchor.constraint(equalTo: underlineView.topAnchor),
            focusedUnderlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            focusedUnderlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            focusedUnderlineView.heightAnchor.constraint(equalToConstant: 2),
            
            // Error label
            errorLabel.topAnchor.constraint(equalTo: underlineView.bottomAnchor, constant: Spacing.micro),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Assistive label
            assistiveLabel.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: Spacing.micro),
            assistiveLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            assistiveLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            assistiveLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupAppearance() {
        backgroundColor = .clear
        
        // Configure text field appearance
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        
        updateFloatingLabel()
    }
    
    private func setupInteractions() {
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupAccessibility() {
        // Make the container accessible instead of individual elements
        isAccessibilityElement = false
        textField.isAccessibilityElement = true
        
        updateAccessibilityLabels()
    }
    
    // MARK: - Text Field Events
    
    @objc private func textFieldDidBeginEditing() {
        animateToFloatingState(true)
        animateFocusState(true)
        clearError()
    }
    
    @objc private func textFieldDidEndEditing() {
        updateFloatingLabel()
        animateFocusState(false)
    }
    
    @objc private func textFieldDidChange() {
        updateFloatingLabel()
        clearError()
    }
    
    // MARK: - Animation
    
    private func updateFloatingLabel() {
        let shouldFloat = !(textField.text?.isEmpty ?? true) || textField.isFirstResponder
        
        if shouldFloat != isFloating {
            animateToFloatingState(shouldFloat)
        }
    }
    
    open func animateToFloatingState(_ shouldFloat: Bool) {
        isFloating = shouldFloat
        
        let topConstant = shouldFloat ? 0 : Spacing.large
        let leadingConstant: CGFloat = 0
        let font = shouldFloat ? UIFont.caption : UIFont.bodySmall
        let color = shouldFloat ? UIColor.accentMint : UIColor.textSecondary
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.floatingLabelTopConstraint.constant = topConstant
                self.floatingLabelLeadingConstraint.constant = leadingConstant
                self.floatingLabel.font = font
                self.floatingLabel.textColor = color
                self.layoutIfNeeded()
            }
        )
        
        // Update placeholder
        textField.placeholder = shouldFloat ? nil : placeholder
    }
    
    private func animateFocusState(_ isFocused: Bool) {
        let scaleX: CGFloat = isFocused ? 1 : 0
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.focusedUnderlineView.transform = CGAffineTransform(scaleX: scaleX, y: 1)
            }
        )
    }
    
    // MARK: - Public Methods
    
    /// Sets error state with message
    func setError(_ message: String?) {
        hasError = message != nil
        errorLabel.text = message
        
        let alpha: CGFloat = hasError ? 1 : 0
        let color = hasError ? UIColor.systemError : UIColor.accentMint
        
        UIView.animate(withDuration: 0.2) {
            self.errorLabel.alpha = alpha
            self.focusedUnderlineView.backgroundColor = color
            self.floatingLabel.textColor = self.isFloating ? color : .textSecondary
        }
        
        if hasError {
            shakeAnimation()
        }
        
        updateAccessibilityLabels()
    }
    
    /// Clears error state
    func clearError() {
        if hasError {
            setError(nil)
        }
    }
    
    /// Sets assistive text
    func setAssistiveText(_ text: String?) {
        assistiveLabel.text = text
        assistiveLabel.isHidden = text == nil
        updateAccessibilityLabels()
    }
    
    /// Makes text field first responder
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    /// Resigns first responder
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - Accessibility
    
    private func updateAccessibilityLabels() {
        var accessibilityText = placeholder ?? ""
        
        if let assistiveText = assistiveLabel.text, !assistiveText.isEmpty {
            accessibilityText += ". \(assistiveText)"
        }
        
        if let errorText = errorLabel.text, !errorText.isEmpty, hasError {
            accessibilityText += ". Error: \(errorText)"
        }
        
        textField.accessibilityLabel = accessibilityText
    }
}

// MARK: - Text Field Variants

/// Email text field with built-in validation
class EmailTextField: ModernTextField {
    
override    init(frame: CGRect) {
        super.init(frame: frame)
        setupEmailField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEmailField()
    }
    
    private func setupEmailField() {
        placeholder = "Email"
        keyboardType = .emailAddress
        returnKeyType = .next
        setAssistiveText("Enter your email address")
    }
    
    /// Validates email format
    func validateEmail() -> Bool {
        guard let email = text, !email.isEmpty else {
            setError("Email is required")
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            setError("Please enter a valid email address")
            return false
        }
        
        clearError()
        return true
    }
}

/// Password text field with visibility toggle
class PasswordTextField: ModernTextField {
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .textSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
override    init(frame: CGRect) {
        super.init(frame: frame)
        setupPasswordField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPasswordField()
    }
    
    private func setupPasswordField() {
        placeholder = "Password"
        isSecureTextEntry = true
        returnKeyType = .done
        
        // Add toggle button
        addSubview(toggleButton)
        NSLayoutConstraint.activate([
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggleButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 44),
            toggleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        isSecureTextEntry.toggle()
        toggleButton.isSelected = !isSecureTextEntry
        
        // Maintain cursor position
        if let existingText = text, isSecureTextEntry {
            textField.deleteBackward()
            textField.insertText(String(existingText.last ?? Character("")))
        }
    }
}
