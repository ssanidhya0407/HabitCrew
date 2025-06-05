import UIKit

protocol HabitCardViewDelegate: AnyObject {
    func didTapCompleteButton(for habit: Habit)
}

class HabitCardView: UIView {
    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    
    private var habit: Habit
    weak var delegate: HabitCardViewDelegate?
    
    init(habit: Habit) {
        self.habit = habit
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.05
        addSubview(containerView)
        
        // Icon Container
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 20
        containerView.addSubview(iconContainer)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainer.addSubview(iconImageView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        // Streak Label
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = UIFont.systemFont(ofSize: 13)
        streakLabel.textColor = .systemGray
        containerView.addSubview(streakLabel)
        
        // Complete Button
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        containerView.addSubview(completeButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
            
            streakLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            streakLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            streakLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
            
            completeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 32),
            completeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Configure with habit data
        configure()
    }
    
    private func configure() {
        // Set color using our helper
        iconContainer.backgroundColor = ColorHelper.color(fromHex: habit.color)
        
        // Set icon
        iconImageView.image = UIImage(systemName: habit.icon)
        
        // Set text
        titleLabel.text = habit.title
        streakLabel.text = "🔥 \(habit.streak) day streak"
        
        // Configure button
        let isCompleted = habit.isCompletedToday()
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "circle", withConfiguration: config)
        completeButton.setImage(image, for: .normal)
        completeButton.tintColor = isCompleted ? .systemGreen : .systemGray3
    }
    
    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(for: habit)
    }
}
