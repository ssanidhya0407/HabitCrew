import UIKit

class HabitCardCell: UICollectionViewCell {
    
    // UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let progressView = UIProgressView()
    private let progressLabel = UILabel()
    private let skeletonLayerColor = UIColor.systemGray5.cgColor
    private var skeletonLayers: [CALayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove any skeleton layers
        for layer in skeletonLayers {
            layer.removeFromSuperlayer()
        }
        skeletonLayers.removeAll()
        
        // Reset content visibility
        titleLabel.text = nil
        progressLabel.text = nil
        iconImageView.image = nil
        progressView.progress = 0
        
        // Reset container appearance
        containerView.backgroundColor = .systemBackground
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOpacity = 0.12
        contentView.addSubview(containerView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.backgroundColor = .systemGray6
        iconImageView.layer.cornerRadius = 18
        iconImageView.layer.masksToBounds = true
        containerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        containerView.addSubview(titleLabel)
        
        // Progress View
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemBlue
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        containerView.addSubview(progressView)
        
        // Progress Label
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = UIFont.systemFont(ofSize: 12)
        progressLabel.textColor = .secondaryLabel
        containerView.addSubview(progressLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            progressLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Missing methods that need to be added
    
    func showSkeleton() {
        // Create and add skeleton layers
        let titleLayer = CALayer()
        titleLayer.frame = CGRect(x: 16, y: 64, width: contentView.bounds.width - 32, height: 20)
        titleLayer.backgroundColor = skeletonLayerColor
        titleLayer.cornerRadius = 4
        
        let iconLayer = CALayer()
        iconLayer.frame = CGRect(x: 16, y: 16, width: 36, height: 36)
        iconLayer.backgroundColor = skeletonLayerColor
        iconLayer.cornerRadius = 18
        
        let progressViewLayer = CALayer()
        progressViewLayer.frame = CGRect(x: 16, y: 100, width: contentView.bounds.width - 32, height: 4)
        progressViewLayer.backgroundColor = skeletonLayerColor
        progressViewLayer.cornerRadius = 2
        
        let progressLabelLayer = CALayer()
        progressLabelLayer.frame = CGRect(x: 16, y: 112, width: 80, height: 12)
        progressLabelLayer.backgroundColor = skeletonLayerColor
        progressLabelLayer.cornerRadius = 2
        
        containerView.layer.addSublayer(titleLayer)
        containerView.layer.addSublayer(iconLayer)
        containerView.layer.addSublayer(progressViewLayer)
        containerView.layer.addSublayer(progressLabelLayer)
        
        skeletonLayers = [titleLayer, iconLayer, progressViewLayer, progressLabelLayer]
        
        // Add animation to skeleton layers
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.6
        animation.toValue = 0.3
        animation.duration = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        for layer in skeletonLayers {
            layer.add(animation, forKey: "pulsating")
        }
    }
    
    // Only updating the configure method
    func configure(with habit: Habit) {
        titleLabel.text = habit.title
        
        // Calculate progress
        let progress: Float
        if habit.isCompletedToday() {
            progress = 1.0
        } else {
            progress = 0.0
        }
        
        // Set progress
        progressView.setProgress(progress, animated: true)
        progressLabel.text = "\(Int(progress * 100))% Complete"
        
        // Set icon and color
        iconImageView.image = UIImage(systemName: habit.icon)
        
        // Use our helper for color
        let themeColor = ColorHelper.color(fromHex: habit.color)
        iconImageView.backgroundColor = themeColor.withAlphaComponent(0.15)
        iconImageView.tintColor = themeColor
        progressView.progressTintColor = themeColor
    }
}
