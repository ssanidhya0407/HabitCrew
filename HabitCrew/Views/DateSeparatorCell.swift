//
//  DateSeparatorCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class DateSeparatorCell: UITableViewCell {
    
    // UI Components
    private let containerView = UIView()
    private let dateLabel = UILabel()
    private let leftLine = UIView()
    private let rightLine = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center
        containerView.addSubview(dateLabel)
        
        // Left Line
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = .systemGray4
        containerView.addSubview(leftLine)
        
        // Right Line
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = .systemGray4
        containerView.addSubview(rightLine)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            leftLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftLine.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            leftLine.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            rightLine.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            rightLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: date)
    }
}