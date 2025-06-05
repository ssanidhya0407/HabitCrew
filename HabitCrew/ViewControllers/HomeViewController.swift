import UIKit

class HomeViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let progressSection = UIView()
    private let progressRingView = CircularProgressView(frame: .zero, lineWidth: 8)
    private let progressLabel = UILabel()
    private let progressDescriptionLabel = UILabel()
    private let todaySection = UIView()
    private let todaySectionLabel = UILabel()
    private let todaySeeAllButton = UIButton(type: .system)
    private let todayStackView = UIStackView()
    private let upcomingSection = UIView()
    private let upcomingSectionLabel = UILabel()
    private let upcomingSeeAllButton = UIButton(type: .system)
    private let habitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: 170, height: 180)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let emptyStateView = EmptyStateView(message: "No habits for today. Let's create one!")
    private let addHabitButton = FloatingActionButton()
    
    // Data
    private var todayHabits: [Habit] = []
    private var allHabits: [Habit] = []
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadHabits()
        updateDateLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Apply gradient to entire view
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: "#4361EE") ?? .systemBlue,
            UIColor(hex: "#3A0CA3") ?? .systemIndigo
        ].map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Update progress ring layout
        progressRingView.layer.cornerRadius = progressRingView.bounds.width / 2
    }
    
    private func setupUI() {
        view.backgroundColor = .systemIndigo
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        
        // Title Label - iOS Health-style
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Home"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        contentView.addSubview(titleLabel)
        
        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dateLabel.textColor = .white
        contentView.addSubview(dateLabel)
        
        // Progress Section
        progressSection.translatesAutoresizingMaskIntoConstraints = false
        progressSection.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        progressSection.layer.cornerRadius = 20
        contentView.addSubview(progressSection)
        
        // Progress Ring View
        progressRingView.translatesAutoresizingMaskIntoConstraints = false
        progressRingView.progressColor = .white
        progressRingView.trackColor = UIColor.white.withAlphaComponent(0.2)
        progressRingView.backgroundColor = UIColor.clear
        progressSection.addSubview(progressRingView)
        
        // Progress Label - Inside ring
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textColor = .white
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        progressLabel.textAlignment = .center
        progressLabel.text = "0%"
        progressRingView.addSubview(progressLabel)
        
        // Progress Description Label
        progressDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        progressDescriptionLabel.textColor = .white
        progressDescriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        progressDescriptionLabel.textAlignment = .center
        progressDescriptionLabel.numberOfLines = 0
        progressDescriptionLabel.text = "Today's Progress"
        progressSection.addSubview(progressDescriptionLabel)
        
        // Today Section
        todaySection.translatesAutoresizingMaskIntoConstraints = false
        todaySection.backgroundColor = .white
        todaySection.layer.cornerRadius = 20
        contentView.addSubview(todaySection)
        
        // Today Section Label
        todaySectionLabel.translatesAutoresizingMaskIntoConstraints = false
        todaySectionLabel.text = "Today's Focus"
        todaySectionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        todaySectionLabel.textColor = .black
        todaySection.addSubview(todaySectionLabel)
        
        // Today See All Button
        todaySeeAllButton.translatesAutoresizingMaskIntoConstraints = false
        todaySeeAllButton.setTitle("See All", for: .normal)
        todaySeeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        todaySeeAllButton.setTitleColor(UIColor(hex: "#4361EE"), for: .normal)
        todaySection.addSubview(todaySeeAllButton)
        
        // Today Stack View
        todayStackView.translatesAutoresizingMaskIntoConstraints = false
        todayStackView.axis = .vertical
        todayStackView.spacing = 15
        todayStackView.distribution = .fillEqually
        todaySection.addSubview(todayStackView)
        
        // Upcoming Section
        upcomingSection.translatesAutoresizingMaskIntoConstraints = false
        upcomingSection.backgroundColor = .white
        upcomingSection.layer.cornerRadius = 20
        contentView.addSubview(upcomingSection)
        
        // Upcoming Section Label
        upcomingSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        upcomingSectionLabel.text = "Upcoming"
        upcomingSectionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        upcomingSectionLabel.textColor = .black
        upcomingSection.addSubview(upcomingSectionLabel)
        
        // Upcoming See All Button
        upcomingSeeAllButton.translatesAutoresizingMaskIntoConstraints = false
        upcomingSeeAllButton.setTitle("See All", for: .normal)
        upcomingSeeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        upcomingSeeAllButton.setTitleColor(UIColor(hex: "#4361EE"), for: .normal)
        upcomingSection.addSubview(upcomingSeeAllButton)
        
        // Habits Collection View
        habitsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        habitsCollectionView.backgroundColor = .clear
        habitsCollectionView.showsHorizontalScrollIndicator = false
        upcomingSection.addSubview(habitsCollectionView)
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        todaySection.addSubview(emptyStateView)
        
        // Add Habit Button
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        view.addSubview(addHabitButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // iOS Health-style title and date layout
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Progress section with circular view
            progressSection.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            progressSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressSection.heightAnchor.constraint(equalToConstant: 150),
            
            progressRingView.centerYAnchor.constraint(equalTo: progressSection.centerYAnchor),
            progressRingView.leadingAnchor.constraint(equalTo: progressSection.leadingAnchor, constant: 25),
            progressRingView.widthAnchor.constraint(equalToConstant: 100),
            progressRingView.heightAnchor.constraint(equalToConstant: 100),
            
            progressLabel.centerXAnchor.constraint(equalTo: progressRingView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: progressRingView.centerYAnchor),
            
            progressDescriptionLabel.centerYAnchor.constraint(equalTo: progressSection.centerYAnchor),
            progressDescriptionLabel.leadingAnchor.constraint(equalTo: progressRingView.trailingAnchor, constant: 20),
            progressDescriptionLabel.trailingAnchor.constraint(equalTo: progressSection.trailingAnchor, constant: -20),
            
            // Today's Focus section
            todaySection.topAnchor.constraint(equalTo: progressSection.bottomAnchor, constant: 24),
            todaySection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            todaySection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            todaySectionLabel.topAnchor.constraint(equalTo: todaySection.topAnchor, constant: 20),
            todaySectionLabel.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: 20),
            
            todaySeeAllButton.centerYAnchor.constraint(equalTo: todaySectionLabel.centerYAnchor),
            todaySeeAllButton.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -20),
            
            todayStackView.topAnchor.constraint(equalTo: todaySectionLabel.bottomAnchor, constant: 15),
            todayStackView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: 20),
            todayStackView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -20),
            todayStackView.bottomAnchor.constraint(equalTo: todaySection.bottomAnchor, constant: -20),
            
            // Upcoming section with horizontal scrolling
            upcomingSection.topAnchor.constraint(equalTo: todaySection.bottomAnchor, constant: 24),
            upcomingSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            upcomingSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            upcomingSectionLabel.topAnchor.constraint(equalTo: upcomingSection.topAnchor, constant: 20),
            upcomingSectionLabel.leadingAnchor.constraint(equalTo: upcomingSection.leadingAnchor, constant: 20),
            
            upcomingSeeAllButton.centerYAnchor.constraint(equalTo: upcomingSectionLabel.centerYAnchor),
            upcomingSeeAllButton.trailingAnchor.constraint(equalTo: upcomingSection.trailingAnchor, constant: -20),
            
            habitsCollectionView.topAnchor.constraint(equalTo: upcomingSectionLabel.bottomAnchor, constant: 15),
            habitsCollectionView.leadingAnchor.constraint(equalTo: upcomingSection.leadingAnchor),
            habitsCollectionView.trailingAnchor.constraint(equalTo: upcomingSection.trailingAnchor),
            habitsCollectionView.bottomAnchor.constraint(equalTo: upcomingSection.bottomAnchor, constant: -20),
            
            // Empty state view
            emptyStateView.centerYAnchor.constraint(equalTo: todaySection.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -20),
            
            // Add habit button
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addHabitButton.widthAnchor.constraint(equalToConstant: 60),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCollectionView() {
        habitsCollectionView.delegate = self
        habitsCollectionView.dataSource = self
        habitsCollectionView.register(HabitCardCell.self, forCellWithReuseIdentifier: "HabitCardCell")
    }
    
    private func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    private func loadHabits() {
        // IMPORTANT: We need to make sure we're actually loading habits
        isLoading = true
        
        // Update UI to show loading state immediately
        updateUI()
        
        // Fetch habits from Firebase
        HabitService.shared.getHabits { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let habits):
                    self.allHabits = habits
                    self.todayHabits = habits.filter { !$0.isCompletedToday() }
                    self.updateProgressRing()
                    self.updateUI()
                    
                case .failure(let error):
                    print("Error loading habits: \(error.localizedDescription)")
                    self.showError(message: "Failed to load your habits")
                }
            }
        }
    }
    
    private func updateProgressRing() {
        // Calculate completion percentage safely
        let totalHabits = max(1, allHabits.count) // Avoid division by zero
        let completedHabits = allHabits.filter { $0.isCompletedToday() }.count
        
        let progress = Float(completedHabits) / Float(totalHabits)
        progressRingView.setProgress(progress, animated: true)
        progressLabel.text = "\(Int(progress * 100))%"
        
        // Update description text
        progressDescriptionLabel.text = "Today's Progress\n\(completedHabits)/\(totalHabits) Habits Completed"
    }
    
    private func updateUI() {
        // Remove any existing habit views
        todayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if isLoading {
            // Show loading skeleton cells
            emptyStateView.isHidden = true
            
            for _ in 0..<3 {
                let skeletonView = HabitItemSkeletonView()
                todayStackView.addArrangedSubview(skeletonView)
            }
            
            habitsCollectionView.reloadData()
            return
        }
        
        // Check if we have habits to show
        if todayHabits.isEmpty {
            emptyStateView.isHidden = false
            // Make sure the empty state view has proper height
            if let constraint = todaySection.constraints.first(where: { $0.firstAttribute == .height }) {
                constraint.isActive = false
            }
            todaySection.heightAnchor.constraint(equalToConstant: 150).isActive = true
        } else {
            emptyStateView.isHidden = true
            
            // Remove height constraint if it exists
            if let constraint = todaySection.constraints.first(where: { $0.firstAttribute == .height }) {
                constraint.isActive = false
            }
            
            // Add habit views to stack
            for habit in todayHabits {
                let habitView = HabitCardView(habit: habit)
                habitView.delegate = self
                todayStackView.addArrangedSubview(habitView)
                
                // Set fixed height for each habit card
                habitView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            }
        }
        
        habitsCollectionView.reloadData()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func addHabitTapped() {
        let addHabitVC = AddHabitViewController()
        addHabitVC.delegate = self
        
        let navController = UINavigationController(rootViewController: addHabitVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 3 : max(allHabits.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! HabitCardCell
        
        if isLoading {
            cell.showSkeleton()
        } else if indexPath.item < allHabits.count {
            cell.configure(with: allHabits[indexPath.item])
        } else {
            // An empty cell as fallback
            cell.showSkeleton()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isLoading, indexPath.item < allHabits.count else { return }
        
        let habitDetailVC = HabitDetailViewController(habit: allHabits[indexPath.item])
        navigationController?.pushViewController(habitDetailVC, animated: true)
    }
}

// MARK: - HabitCardViewDelegate
extension HomeViewController: HabitCardViewDelegate {
    func didTapCompleteButton(for habit: Habit) {
        // Show completion animation
        HapticFeedback.success()
        
        // For testing, immediately update UI without service call
        #if DEBUG
        if let index = allHabits.firstIndex(where: { $0.id == habit.id }) {
            // Update the habit (this might need to be adjusted based on your Habit implementation)
            var updatedHabit = habit
            // Assuming you have some method to mark a habit complete
            // This would typically update lastCompletedDate to today
            // For now, we're just creating a visual effect
            
            allHabits[index] = updatedHabit
            
            // Update UI after "completing" the habit
            if let index = todayHabits.firstIndex(where: { $0.id == habit.id }) {
                todayHabits.remove(at: index)
            }
            
            updateProgressRing()
            updateUI()
        }
        #else
        // Your actual habit completion code
        HabitService.shared.completeHabit(habitId: habit.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.loadHabits() // Reload to update UI
                    
                case .failure(let error):
                    print("Error completing habit: \(error.localizedDescription)")
                    self.showError(message: "Failed to mark habit as completed")
                }
            }
        }
        #endif
    }
}

// MARK: - AddHabitViewControllerDelegate
extension HomeViewController: AddHabitViewControllerDelegate {
    func didAddHabit() {
        loadHabits()
    }
}

// MARK: - UI Helper Views
class HabitItemSkeletonView: UIView {
    
    private let containerView = UIView()
    private let iconView = UIView()
    private let titleView = UIView()
    private let subtitleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startShimmering()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        addSubview(containerView)
        
        // Icon placeholder
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor.systemGray5
        iconView.layer.cornerRadius = 20
        containerView.addSubview(iconView)
        
        // Title placeholder
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor.systemGray5
        titleView.layer.cornerRadius = 4
        containerView.addSubview(titleView)
        
        // Subtitle placeholder
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.backgroundColor = UIColor.systemGray5
        subtitleView.layer.cornerRadius = 4
        containerView.addSubview(subtitleView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            titleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleView.widthAnchor.constraint(equalToConstant: 120),
            titleView.heightAnchor.constraint(equalToConstant: 16),
            
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            subtitleView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            subtitleView.widthAnchor.constraint(equalToConstant: 80),
            subtitleView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    private func startShimmering() {
        let views = [iconView, titleView, subtitleView]
        
        views.forEach { view in
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.6
            animation.toValue = 0.9
            animation.duration = 1
            animation.autoreverses = true
            animation.repeatCount = .infinity
            view.layer.add(animation, forKey: "shimmer")
        }
    }
}

// Haptic feedback helper
class HapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview("HomeViewController")
{
    HomeViewController()
}
