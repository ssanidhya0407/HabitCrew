//
//  MessageBannerView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class MessageBannerView: UIView {
    
    // UI Components
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    
    // Properties
    private var tapAction: (() -> Void)?
    
    init(senderName: String, messagePreview: String) {
        super.init(frame: .zero)
        
        titleLabel.text = senderName
        messageLabel.text = messagePreview
        
        setupUI()
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOpacity = 0.1
        addSubview(containerView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        containerView.addSubview(titleLabel)
        
        // Message Label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 1
        containerView.addSubview(messageLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Set initial state for animation
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -20)
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    func show(completion: @escaping () -> Void) {
        tapAction = completion
        
        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
        
        // Automatically dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.dismiss()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -20)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    @objc private func viewTapped() {
        tapAction?()
        dismiss()
    }
}