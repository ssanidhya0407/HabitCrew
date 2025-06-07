//
//  CircularProgressView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  CircularProgressView.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Circular Progress View - Enhanced version for habit tracking
//

import UIKit

/// Enhanced circular progress view with percentage display and smooth animations
class CircularProgressView: UIView {
    
    // MARK: - Properties
    
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    private let percentageLabel = UILabel()
    private let centerLabel = UILabel()
    
    private var _progress: Float = 0
    
    var progress: Float {
        get { return _progress }
        set { setProgress(newValue, animated: true) }
    }
    
    var progressColor: UIColor = .accentMint {
        didSet { updateColors() }
    }
    
    var trackColor: UIColor = UIColor.white.withAlphaComponent(0.3) {
        didSet { updateColors() }
    }
    
    var lineWidth: CGFloat = 12 {
        didSet { updateLayers() }
    }
    
    var showPercentage: Bool = true {
        didSet { percentageLabel.isHidden = !showPercentage }
    }
    
    var centerText: String? {
        didSet { 
            centerLabel.text = centerText
            centerLabel.isHidden = centerText == nil
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    convenience init(frame: CGRect, lineWidth: CGFloat) {
        self.init(frame: frame)
        self.lineWidth = lineWidth
        updateLayers()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        setupLayers()
        setupLabels()
        setupAccessibility()
    }
    
    private func setupLayers() {
        // Background circle
        backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = trackColor.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        // Progress circle
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func setupLabels() {
        // Percentage label
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.font = .headline
        percentageLabel.textColor = .white
        percentageLabel.textAlignment = .center
        percentageLabel.text = "0%"
        addSubview(percentageLabel)
        
        // Center label
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        centerLabel.font = .caption
        centerLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        centerLabel.textAlignment = .center
        centerLabel.numberOfLines = 2
        centerLabel.isHidden = true
        addSubview(centerLabel)
        
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 2),
            centerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            centerLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ])
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently
        updateAccessibilityValue()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    private func updateColors() {
        backgroundLayer?.strokeColor = trackColor.cgColor
        progressLayer?.strokeColor = progressColor.cgColor
    }
    
    // MARK: - Progress Updates
    
    func setProgress(_ progress: Float, animated: Bool = true) {
        let clampedProgress = max(0, min(1, progress))
        _progress = clampedProgress
        
        let strokeEnd = CGFloat(clampedProgress)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = strokeEnd
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.strokeEnd = strokeEnd
        
        // Update percentage label
        let percentage = Int(clampedProgress * 100)
        percentageLabel.text = "\(percentage)%"
        
        updateAccessibilityValue()
        
        // Add celebration animation for 100%
        if clampedProgress >= 1.0 && animated {
            celebrateCompletion()
        }
    }
    
    private func celebrateCompletion() {
        // Scale animation
        animateSpring(duration: 0.6, dampingRatio: 0.6) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            self.animateSpring(duration: 0.3) {
                self.transform = .identity
            }
        }
        
        // Color pulse animation
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = progressColor.cgColor
        colorAnimation.toValue = UIColor.systemGreen.cgColor
        colorAnimation.duration = 0.3
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = 2
        
        progressLayer.add(colorAnimation, forKey: "colorPulse")
    }
    
    // MARK: - Accessibility
    
    private func updateAccessibilityValue() {
        let percentage = Int(_progress * 100)
        accessibilityValue = "\(percentage) percent complete"
        accessibilityLabel = "Progress indicator"
    }
    
    // MARK: - Public Methods
    
    /// Resets progress to zero with animation
    func resetProgress(animated: Bool = true) {
        setProgress(0, animated: animated)
    }
    
    /// Sets progress to 100% with celebration
    func completeProgress(animated: Bool = true) {
        setProgress(1.0, animated: animated)
    }
    
    /// Adds a subtle pulse animation
    func pulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.add(pulse, forKey: "pulse")
    }
}