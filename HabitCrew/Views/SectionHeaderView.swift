//
//  SectionHeaderView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class SectionHeaderView: UIView {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        addSubview(containerView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        containerView.addSubview(titleLabel)
        
        // See All Button
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        seeAllButton.tintColor = .systemBlue
        containerView.addSubview(seeAllButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
            
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            seeAllButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
}
