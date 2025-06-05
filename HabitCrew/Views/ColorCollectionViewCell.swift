//
//  ColorCollectionViewCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    private let colorView = UIView()
    private let selectedIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Color View
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 20
        contentView.addSubview(colorView)
        
        // Selected Indicator
        selectedIndicator.translatesAutoresizingMaskIntoConstraints = false
        selectedIndicator.backgroundColor = .clear
        selectedIndicator.layer.cornerRadius = 20
        selectedIndicator.layer.borderWidth = 3
        selectedIndicator.layer.borderColor = UIColor.systemBlue.cgColor
        selectedIndicator.isHidden = true
        contentView.addSubview(selectedIndicator)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            selectedIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with colorHex: String, isSelected: Bool) {
        colorView.backgroundColor = UIColor(hex: colorHex) ?? .lightGray
        selectedIndicator.isHidden = !isSelected
    }
}