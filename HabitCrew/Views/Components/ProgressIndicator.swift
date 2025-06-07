//
//  ProgressIndicator.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  ProgressIndicator.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Design System Foundation - Progress Indicator Component
//

import UIKit

/// Modern progress indicator with smooth animations
/// Perfect for habit tracking progress visualization
class ProgressIndicator: UIView {
    
    // MARK: - Style
    
    enum Style {
        case linear
        case circular
        case ring
    }
    
    // MARK: - Properties
    
    private var style: Style = .linear
    private var progressLayer: CALayer?
    private var backgroundLayer: CALayer?
    private var gradientLayer: CAGradientLayer?
    
    private var _progress: CGFloat = 0
    
    /// Progress value between 0.0 and 1.0
    var progress: CGFloat {
        get { _progress }
        set { setProgress(newValue, animated: true) }
    }
    
    var progressColor: UIColor = .accentMint {
        didSet { updateAppearance() }
    }
    
    var trackColor: UIColor = .border {
        didSet { updateAppearance() }
    }
    
    var lineWidth: CGFloat = 8 {
        didSet { updateAppearance() }
    }
    
    var useGradient: Bool = true {
        didSet { updateAppearance() }
    }
    
    // MARK: - Initialization
    
    init(style: Style = .linear) {
        self.style = style
        super.init(frame: .zero)
        setupProgressIndicator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupProgressIndicator()
    }
    
    // MARK: - Setup
    
    private func setupProgressIndicator() {
        backgroundColor = .clear
        setupLayers()
        setupAccessibility()
    }
    
    private func setupLayers() {
        switch style {
        case .linear:
            setupLinearProgress()
        case .circular:
            setupCircularProgress()
        case .ring:
            setupRingProgress()
        }
    }
    
    private func setupLinearProgress() {
        // Background track
        let background = CALayer()
        background.backgroundColor = trackColor.cgColor
        background.cornerRadius = lineWidth / 2
        layer.addSublayer(background)
        backgroundLayer = background
        
        // Progress layer
        let progress = CALayer()
        progress.backgroundColor = progressColor.cgColor
        progress.cornerRadius = lineWidth / 2
        layer.addSublayer(progress)
        progressLayer = progress
        
        // Gradient layer
        if useGradient {
            let gradient = CAGradientLayer()
            gradient.colors = DesignTokens.Gradients.mintPurple
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.cornerRadius = lineWidth / 2
            layer.addSublayer(gradient)
            gradientLayer = gradient
        }
    }
    
    private func setupCircularProgress() {
        // Background circle
        let backgroundPath = UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2))
        let background = CAShapeLayer()
        background.path = backgroundPath.cgPath
        background.strokeColor = trackColor.cgColor
        background.fillColor = UIColor.clear.cgColor
        background.lineWidth = lineWidth
        layer.addSublayer(background)
        backgroundLayer = background
        
        // Progress circle
        let progressPath = UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2))
        let progress = CAShapeLayer()
        progress.path = progressPath.cgPath
        progress.strokeColor = progressColor.cgColor
        progress.fillColor = UIColor.clear.cgColor
        progress.lineWidth = lineWidth
        progress.lineCap = .round
        progress.strokeEnd = 0
        layer.addSublayer(progress)
        progressLayer = progress
    }
    
    private func setupRingProgress() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        
        // Background ring
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
        let background = CAShapeLayer()
        background.path = backgroundPath.cgPath
        background.strokeColor = trackColor.cgColor
        background.fillColor = UIColor.clear.cgColor
        background.lineWidth = lineWidth
        layer.addSublayer(background)
        backgroundLayer = background
        
        // Progress ring
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
        let progress = CAShapeLayer()
        progress.path = progressPath.cgPath
        progress.strokeColor = progressColor.cgColor
        progress.fillColor = UIColor.clear.cgColor
        progress.lineWidth = lineWidth
        progress.lineCap = .round
        progress.strokeEnd = 0
        layer.addSublayer(progress)
        progressLayer = progress
        
        // Gradient for ring
        if useGradient {
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = DesignTokens.Gradients.mintPurple
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.mask = progress
            layer.addSublayer(gradient)
            gradientLayer = gradient
        }
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently
        updateAccessibilityValue()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }
    
    private func updateLayerFrames() {
        switch style {
        case .linear:
            backgroundLayer?.frame = CGRect(x: 0, y: (bounds.height - lineWidth) / 2, width: bounds.width, height: lineWidth)
            updateLinearProgress()
        case .circular, .ring:
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
            
            if let shapeLayer = progressLayer as? CAShapeLayer {
                let path = style == .circular ? 
                    UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2)) :
                    UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
                shapeLayer.path = path.cgPath
            }
            
            if let shapeLayer = backgroundLayer as? CAShapeLayer {
                let path = style == .circular ? 
                    UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2)) :
                    UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: true)
                shapeLayer.path = path.cgPath
            }
            
            gradientLayer?.frame = bounds
        }
    }
    
    // MARK: - Progress Updates
    
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0, min(1, progress))
        _progress = clampedProgress
        
        if animated {
            animateProgress(to: clampedProgress)
        } else {
            updateProgressImmediately(to: clampedProgress)
        }
        
        updateAccessibilityValue()
    }
    
    private func animateProgress(to progress: CGFloat) {
        switch style {
        case .linear:
            animateLinearProgress(to: progress)
        case .circular, .ring:
            animateCircularProgress(to: progress)
        }
    }
    
    private func animateLinearProgress(to progress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = progressLayer?.bounds.width ?? 0
        animation.toValue = bounds.width * progress
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        progressLayer?.add(animation, forKey: "widthAnimation")
        updateLinearProgress()
        
        gradientLayer?.add(animation, forKey: "gradientAnimation")
    }
    
    private func animateCircularProgress(to progress: CGFloat) {
        guard let shapeLayer = progressLayer as? CAShapeLayer else { return }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = shapeLayer.strokeEnd
        animation.toValue = progress
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shapeLayer.add(animation, forKey: "progressAnimation")
        shapeLayer.strokeEnd = progress
    }
    
    private func updateProgressImmediately(to progress: CGFloat) {
        switch style {
        case .linear:
            updateLinearProgress()
        case .circular, .ring:
            if let shapeLayer = progressLayer as? CAShapeLayer {
                shapeLayer.strokeEnd = progress
            }
        }
    }
    
    private func updateLinearProgress() {
        let progressWidth = bounds.width * _progress
        progressLayer?.bounds = CGRect(x: 0, y: 0, width: progressWidth, height: lineWidth)
        progressLayer?.position = CGPoint(x: progressWidth / 2, y: bounds.midY)
        
        gradientLayer?.bounds = CGRect(x: 0, y: 0, width: progressWidth, height: lineWidth)
        gradientLayer?.position = CGPoint(x: progressWidth / 2, y: bounds.midY)
    }
    
    // MARK: - Appearance
    
    private func updateAppearance() {
        progressLayer?.backgroundColor = progressColor.cgColor
        backgroundLayer?.backgroundColor = trackColor.cgColor
        
        if let shapeLayer = progressLayer as? CAShapeLayer {
            shapeLayer.strokeColor = progressColor.cgColor
            shapeLayer.lineWidth = lineWidth
        }
        
        if let shapeLayer = backgroundLayer as? CAShapeLayer {
            shapeLayer.strokeColor = trackColor.cgColor
            shapeLayer.lineWidth = lineWidth
        }
        
        if useGradient && gradientLayer == nil {
            setupLayers()
        } else if !useGradient {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
        }
    }
    
    // MARK: - Accessibility
    
    private func updateAccessibilityValue() {
        let percentage = Int(_progress * 100)
        accessibilityValue = "\(percentage) percent complete"
        accessibilityLabel = "Progress indicator"
    }
    
    // MARK: - Public Methods
    
    /// Increments progress by a given amount
    func incrementProgress(by amount: CGFloat, animated: Bool = true) {
        setProgress(_progress + amount, animated: animated)
    }
    
    /// Resets progress to zero
    func resetProgress(animated: Bool = true) {
        setProgress(0, animated: animated)
    }
    
    /// Completes progress (sets to 1.0)
    func completeProgress(animated: Bool = true) {
        setProgress(1.0, animated: animated)
    }
    
    /// Pulse animation for attention
    func pulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.autoreverses = true
        pulse.repeatCount = 2
        progressLayer?.add(pulse, forKey: "pulse")
    }
}

// MARK: - Factory Methods

extension ProgressIndicator {
    
    /// Creates a linear progress bar
    static func linear(height: CGFloat = 8) -> ProgressIndicator {
        let indicator = ProgressIndicator(style: .linear)
        indicator.lineWidth = height
        return indicator
    }
    
    /// Creates a circular progress indicator
    static func circular(diameter: CGFloat = 60) -> ProgressIndicator {
        let indicator = ProgressIndicator(style: .circular)
        indicator.setSize(width: diameter, height: diameter)
        return indicator
    }
    
    /// Creates a ring progress indicator
    static func ring(diameter: CGFloat = 80, lineWidth: CGFloat = 8) -> ProgressIndicator {
        let indicator = ProgressIndicator(style: .ring)
        indicator.lineWidth = lineWidth
        indicator.setSize(width: diameter, height: diameter)
        return indicator
    }
}