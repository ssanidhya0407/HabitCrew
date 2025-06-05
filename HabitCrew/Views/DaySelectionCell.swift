//
//  DaySelectionCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class DaySelectionCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let dayLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        contentView.addSubview(containerView)
        
        // Day Label
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.textAlignment = .center
        dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        containerView.addSubview(dayLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(with day: String, isSelected: Bool) {
        dayLabel.text = day
        setSelected(isSelected)
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            containerView.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
            dayLabel.textColor = .white
        } else {
            containerView.backgroundColor = .systemGray6
            dayLabel.textColor = .label
        }
        
        // Add animation
        UIView.animate(withDuration: 0.2) {
            self.transform = isSelected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
        }
    }
}