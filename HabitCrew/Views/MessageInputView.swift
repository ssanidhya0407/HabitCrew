//
//  MessageInputView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func messageInputView(_ view: MessageInputView, didSendMessage text: String)
}

class MessageInputView: UIView {
    
    // UI Components
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let attachButton = UIButton(type: .system)
    
    weak var delegate: MessageInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Add a top separator line
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .systemGray4
        addSubview(separatorView)
        
        // Attach Button
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        attachButton.tintColor = .systemBlue
        addSubview(attachButton)
        
        // Text View
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        addSubview(textView)
        
        // Send Button
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        addSubview(sendButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            attachButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            attachButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: 30),
            attachButton.heightAnchor.constraint(equalToConstant: 30),
            
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure() {
        textView.delegate = self
        textView.placeholder = "Type a message..."
    }
    
    func clearText() {
        textView.text = ""
        textViewDidChange(textView)
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        delegate?.messageInputView(self, didSendMessage: text)
    }
}

// MARK: - UITextViewDelegate
extension MessageInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Dynamic height adjustment if needed
    }
}

// Placeholder extension for UITextView
extension UITextView {
    private struct AssociatedKeys {
        static var placeholder = "placeholder"
        static var placeholderLabel = "placeholderLabel"
    }
    
    private var placeholderLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var placeholder: String? {
        get {
            return placeholderLabel?.text
        }
        set {
            if placeholderLabel == nil {
                placeholderLabel = UILabel()
                placeholderLabel?.font = self.font
                placeholderLabel?.textColor = .placeholderText
                placeholderLabel?.numberOfLines = 0
                placeholderLabel?.translatesAutoresizingMaskIntoConstraints = false
                
                if let placeholderLabel = placeholderLabel {
                    addSubview(placeholderLabel)
                    NSLayoutConstraint.activate([
                        placeholderLabel.leadingAnchor.constraint(equalTo: textContainerInset.left == 0 ? leadingAnchor : leadingAnchor, constant: textContainerInset.left + 4),
                        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right),
                        placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
                        placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -textContainerInset.bottom)
                    ])
                }
                
                NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
            }
            
            placeholderLabel?.text = newValue
            placeholderLabel?.isHidden = !text.isEmpty
        }
    }
    
    @objc private func textDidChange() {
        placeholderLabel?.isHidden = !text.isEmpty
    }
}
