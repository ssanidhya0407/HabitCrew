//
//  SectionTitleView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class SectionTitleView: UIView {
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
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addSubview(titleLabel)
        
        // See All Button
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addSubview(seeAllButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            seeAllButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}