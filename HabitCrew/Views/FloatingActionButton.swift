//
//  FloatingActionButton.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class FloatingActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .systemBlue
        tintColor = .white
        layer.cornerRadius = 30
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        
        // Set plus icon
        setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)), for: .normal)
        
        // Add visual feedback
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOpacity = 0.1
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.15) {
            self.transform = .identity
            self.layer.shadowOpacity = 0.2
        }
    }
}