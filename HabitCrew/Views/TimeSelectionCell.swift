//
//  TimeSelectionCell.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//
import UIKit

protocol TimeSelectionCellDelegate: AnyObject {
    func didTapEditButton(for cell: TimeSelectionCell)
    func didTapDeleteButton(for cell: TimeSelectionCell)
}

class TimeSelectionCell: UITableViewCell {
    
    private let containerView = UIView()
    private let timeLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let clockImageView = UIImageView()
    
    weak var delegate: TimeSelectionCellDelegate?
    
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
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.addSubview(containerView)
        
        // Clock Image View
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        clockImageView.image = UIImage(systemName: "clock.fill")
        clockImageView.tintColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        clockImageView.contentMode = .scaleAspectFit
        containerView.addSubview(clockImageView)
        
        // Time Label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 17)
        containerView.addSubview(timeLabel)
        
        // Edit Button
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .systemBlue
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        containerView.addSubview(editButton)
        
        // Delete Button
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        containerView.addSubview(deleteButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            clockImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            clockImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clockImageView.widthAnchor.constraint(equalToConstant: 20),
            clockImageView.heightAnchor.constraint(equalToConstant: 20),
            
            timeLabel.leadingAnchor.constraint(equalTo: clockImageView.trailingAnchor, constant: 16),
            timeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with time: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: time)
    }
    
    @objc private func editButtonTapped() {
        delegate?.didTapEditButton(for: self)
    }
    
    @objc private func deleteButtonTapped() {
        delegate?.didTapDeleteButton(for: self)
    }
}
