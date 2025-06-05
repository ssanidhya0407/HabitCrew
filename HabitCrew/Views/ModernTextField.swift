//
//  ModernTextField.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class ModernTextField: UIView {
    
    private let textField = UITextField()
    private let placeholderLabel = UILabel()
    private let bottomLine = UIView()
    
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    init(placeholder: String) {
        super.init(frame: .zero)
        placeholderLabel.text = placeholder
        textField.placeholder = placeholder
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Text Field
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.borderStyle = .none
        textField.delegate = self
        addSubview(textField)
        
        // Bottom Line
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = UIColor.systemGray4
        addSubview(bottomLine)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -2.5, 2.5, 0]
        layer.add(animation, forKey: "shake")
        
        // Highlight field in red
        bottomLine.backgroundColor = .systemRed
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.bottomLine.backgroundColor = UIColor.systemGray4
        }
    }
}

// MARK: - UITextFieldDelegate
extension ModernTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Animate the bottom line when text field becomes active
        UIView.animate(withDuration: 0.2) {
            self.bottomLine.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
            self.bottomLine.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Reset the bottom line when text field is no longer active
        UIView.animate(withDuration: 0.2) {
            self.bottomLine.backgroundColor = UIColor.systemGray4
            self.bottomLine.transform = .identity
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}