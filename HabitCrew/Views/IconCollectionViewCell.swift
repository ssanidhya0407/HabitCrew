//
//  IconCollectionViewCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView()
    private let backgroundCircleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Background Circle View
        backgroundCircleView.translatesAutoresizingMaskIntoConstraints = false
        backgroundCircleView.layer.cornerRadius = 20
        backgroundCircleView.backgroundColor = .systemGray6
        contentView.addSubview(backgroundCircleView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemGray
        contentView.addSubview(iconImageView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            backgroundCircleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCircleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundCircleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundCircleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with iconName: String, isSelected: Bool) {
        iconImageView.image = UIImage(systemName: iconName)
        
        if isSelected {
            backgroundCircleView.backgroundColor = .systemBlue
            iconImageView.tintColor = .white
        } else {
            backgroundCircleView.backgroundColor = .systemGray6
            iconImageView.tintColor = .systemGray
        }
    }
}