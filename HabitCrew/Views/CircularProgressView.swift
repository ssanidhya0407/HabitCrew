//
//  CircularProgressView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class CircularProgressView: UIView {
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var percentageLabel = UILabel()
    
    private var lineWidth: CGFloat
    var progressColor: UIColor = .systemBlue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor: UIColor = .systemGray5 {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    init(frame: CGRect, lineWidth: CGFloat) {
        self.lineWidth = lineWidth
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        self.lineWidth = 10
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Track Layer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2),
                                         radius: (min(frame.width, frame.height) - lineWidth)/2,
                                         startAngle: -CGFloat.pi / 2,
                                         endAngle: 3 * CGFloat.pi / 2,
                                         clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // Progress Layer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        // Percentage Label
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        percentageLabel.textColor = .white
        addSubview(percentageLabel)
        
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update layers with new bounds
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                                         radius: (min(bounds.width, bounds.height) - lineWidth)/2,
                                         startAngle: -CGFloat.pi / 2,
                                         endAngle: 3 * CGFloat.pi / 2,
                                         clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        let finalProgress = max(0, min(progress, 1))
        
        // Update percentage label
        percentageLabel.text = "\(Int(finalProgress * 100))%"
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = CGFloat(finalProgress)
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = CGFloat(finalProgress)
            progressLayer.add(animation, forKey: "animateProgress")
        } else {
            progressLayer.strokeEnd = CGFloat(finalProgress)
        }
    }
}