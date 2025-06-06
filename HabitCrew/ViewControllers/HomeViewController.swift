import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let profileButton = UIButton()
    
    // Summary section
    private let summaryCard = UIView()
    private let progressRingView = CircularProgressView(frame: .zero, lineWidth: 12)
    private let summaryTitleLabel = UILabel()
    private let summaryDescriptionLabel = UILabel()
    
    // Today's Habits section
    private let todaySection = UIView()
    private let todayTitleView = UIView()
    private let todaySectionLabel = UILabel()
    private let todaySeeAllButton = UIButton(type: .system)
    
    // Compact grid view for habits
    private let habitGridView = UIView()
    private let habitGridFlowLayout = UICollectionViewFlowLayout()
    private lazy var habitGridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: habitGridFlowLayout)
    
    // Stack view for habits (when few habits)
    private let todayStackView = UIStackView()
    private let emptyStateView = EmptyStateView(message: "No habits for today")
    
    // Other Habits section
    private let otherHabitsSection = UIView()
    private let otherHabitsHeader = UIView()
    private let otherHabitsLabel = UILabel()
    private let otherHabitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 300, height: 170)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Categories section
    private let categoriesSection = UIView()
    private let categoriesLabel = UILabel()
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 120, height: 120)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Bottom UI
    private let addHabitButton = HealthStyleFloatingButton()
    
    // Data
    private var todayHabits: [Habit] = []
    private var otherHabits: [Habit] = []
    private var allHabits: [Habit] = []
    private var isLoading = true
    
    // Constants
    private let maxStackViewHabits = 3 // Show stack view when habits <= this number
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
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
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemBackground
        scrollView.addSubview(contentView)
        
        setupHeaderSection()
        setupSummarySection()
        setupTodayHabitsSection()
        setupOtherHabitsSection()
        setupCategoriesSection()
        setupAddButton()
        
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
        ])
    }
    
    private func setupHeaderSection() {
        // Header View - iOS Health Style
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        contentView.addSubview(headerView)
        
        // Title Label - Large Bold
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Summary"
        titleLabel.textColor = .label
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerView.addSubview(titleLabel)
        
        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        headerView.addSubview(dateLabel)
        
        // Profile Button
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        profileButton.tintColor = .systemBlue
        profileButton.contentHorizontalAlignment = .right
        let profileConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        profileButton.setPreferredSymbolConfiguration(profileConfig, forImageIn: .normal)
        headerView.addSubview(profileButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            profileButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            profileButton.widthAnchor.constraint(equalToConstant: 44),
            profileButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupSummarySection() {
        // Summary Card - Health App Style
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.backgroundColor = .systemBlue
        summaryCard.layer.cornerRadius = 16
        contentView.addSubview(summaryCard)
        
        // Progress Ring
        progressRingView.translatesAutoresizingMaskIntoConstraints = false
        progressRingView.progressColor = .white
        progressRingView.trackColor = UIColor.white.withAlphaComponent(0.3)
        progressRingView.backgroundColor = .clear
        summaryCard.addSubview(progressRingView)
        
        // Summary Title
        summaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryTitleLabel.text = "Today's Progress"
        summaryTitleLabel.textColor = .white
        summaryTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        summaryCard.addSubview(summaryTitleLabel)
        
        // Summary Description
        summaryDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryDescriptionLabel.textColor = .white
        summaryDescriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        summaryDescriptionLabel.numberOfLines = 0
        summaryCard.addSubview(summaryDescriptionLabel)
        
        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summaryCard.heightAnchor.constraint(equalToConstant: 160),
            
            progressRingView.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            progressRingView.centerYAnchor.constraint(equalTo: summaryCard.centerYAnchor),
            progressRingView.widthAnchor.constraint(equalToConstant: 115),
            progressRingView.heightAnchor.constraint(equalToConstant: 115),
            
            summaryTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 24),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: progressRingView.trailingAnchor, constant: 16),
            summaryTitleLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            
            summaryDescriptionLabel.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 8),
            summaryDescriptionLabel.leadingAnchor.constraint(equalTo: progressRingView.trailingAnchor, constant: 16),
            summaryDescriptionLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupTodayHabitsSection() {
        // Today Section
        todaySection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(todaySection)
        
        // Today Title View
        todayTitleView.translatesAutoresizingMaskIntoConstraints = false
        todaySection.addSubview(todayTitleView)
        
        // Today Section Label
        todaySectionLabel.translatesAutoresizingMaskIntoConstraints = false
        todaySectionLabel.text = "Today's Habits"
        todaySectionLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        todaySectionLabel.textColor = .label
        todayTitleView.addSubview(todaySectionLabel)
        
        // See All Button
        todaySeeAllButton.translatesAutoresizingMaskIntoConstraints = false
        todaySeeAllButton.setTitle("See All", for: .normal)
        todaySeeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        todaySeeAllButton.setTitleColor(.systemBlue, for: .normal)
        todaySeeAllButton.addTarget(self, action: #selector(seeAllTodayHabits), for: .touchUpInside)
        todayTitleView.addSubview(todaySeeAllButton)
        
        // Today Stack View (for few habits)
        todayStackView.translatesAutoresizingMaskIntoConstraints = false
        todayStackView.axis = .vertical
        todayStackView.spacing = 12
        todayStackView.distribution = .fillEqually
        todaySection.addSubview(todayStackView)
        
        // Setup grid collection view (for many habits)
        habitGridFlowLayout.minimumLineSpacing = 10
        habitGridFlowLayout.minimumInteritemSpacing = 10
        let screenWidth = UIScreen.main.bounds.width
        // Use 3 items per row with more spacing for better visibility
        let itemSize = (screenWidth - 70) / 3
        habitGridFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        habitGridFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        habitGridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        habitGridCollectionView.backgroundColor = .clear
        habitGridCollectionView.showsVerticalScrollIndicator = false
        habitGridCollectionView.isScrollEnabled = false
        habitGridCollectionView.register(CompactHabitCell.self, forCellWithReuseIdentifier: "CompactHabitCell")
        todaySection.addSubview(habitGridCollectionView)
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        todaySection.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            todaySection.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 24),
            todaySection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            todaySection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            todayTitleView.topAnchor.constraint(equalTo: todaySection.topAnchor),
            todayTitleView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor),
            todayTitleView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor),
            todayTitleView.heightAnchor.constraint(equalToConstant: 44),
            
            todaySectionLabel.leadingAnchor.constraint(equalTo: todayTitleView.leadingAnchor, constant: 20),
            todaySectionLabel.centerYAnchor.constraint(equalTo: todayTitleView.centerYAnchor),
            
            todaySeeAllButton.trailingAnchor.constraint(equalTo: todayTitleView.trailingAnchor, constant: -20),
            todaySeeAllButton.centerYAnchor.constraint(equalTo: todayTitleView.centerYAnchor),
            
            todayStackView.topAnchor.constraint(equalTo: todayTitleView.bottomAnchor, constant: 8),
            todayStackView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: 20),
            todayStackView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -20),
            todayStackView.bottomAnchor.constraint(equalTo: todaySection.bottomAnchor),
            
            habitGridCollectionView.topAnchor.constraint(equalTo: todayTitleView.bottomAnchor, constant: 8),
            habitGridCollectionView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: 20),
            habitGridCollectionView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -20),
            habitGridCollectionView.bottomAnchor.constraint(equalTo: todaySection.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: todayTitleView.bottomAnchor, constant: 20),
            emptyStateView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -20),
            emptyStateView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupOtherHabitsSection() {
        // Other Habits Section
        otherHabitsSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(otherHabitsSection)
        
        // Other Habits Header
        otherHabitsHeader.translatesAutoresizingMaskIntoConstraints = false
        otherHabitsSection.addSubview(otherHabitsHeader)
        
        // Other Habits Label
        otherHabitsLabel.translatesAutoresizingMaskIntoConstraints = false
        otherHabitsLabel.text = "Other Habits"
        otherHabitsLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        otherHabitsLabel.textColor = .label
        otherHabitsHeader.addSubview(otherHabitsLabel)
        
        // Other Habits Collection View
        otherHabitsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        otherHabitsCollectionView.backgroundColor = .clear
        otherHabitsCollectionView.showsHorizontalScrollIndicator = false
        otherHabitsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        otherHabitsSection.addSubview(otherHabitsCollectionView)
        
        NSLayoutConstraint.activate([
            otherHabitsSection.topAnchor.constraint(equalTo: todaySection.bottomAnchor, constant: 24),
            otherHabitsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            otherHabitsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            otherHabitsSection.heightAnchor.constraint(equalToConstant: 240),
            
            otherHabitsHeader.topAnchor.constraint(equalTo: otherHabitsSection.topAnchor),
            otherHabitsHeader.leadingAnchor.constraint(equalTo: otherHabitsSection.leadingAnchor),
            otherHabitsHeader.trailingAnchor.constraint(equalTo: otherHabitsSection.trailingAnchor),
            otherHabitsHeader.heightAnchor.constraint(equalToConstant: 44),
            
            otherHabitsLabel.leadingAnchor.constraint(equalTo: otherHabitsHeader.leadingAnchor, constant: 20),
            otherHabitsLabel.centerYAnchor.constraint(equalTo: otherHabitsHeader.centerYAnchor),
            
            otherHabitsCollectionView.topAnchor.constraint(equalTo: otherHabitsHeader.bottomAnchor, constant: 8),
            otherHabitsCollectionView.leadingAnchor.constraint(equalTo: otherHabitsSection.leadingAnchor),
            otherHabitsCollectionView.trailingAnchor.constraint(equalTo: otherHabitsSection.trailingAnchor),
            otherHabitsCollectionView.bottomAnchor.constraint(equalTo: otherHabitsSection.bottomAnchor)
        ])
    }
    
    private func setupCategoriesSection() {
        // Categories Section
        categoriesSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoriesSection)
        
        // Categories Label
        categoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        categoriesLabel.text = "Categories"
        categoriesLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        categoriesLabel.textColor = .label
        categoriesSection.addSubview(categoriesLabel)
        
        // Categories Collection View
        categoriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoriesCollectionView.backgroundColor = .clear
        categoriesCollectionView.showsHorizontalScrollIndicator = false
        categoriesSection.addSubview(categoriesCollectionView)
        
        NSLayoutConstraint.activate([
            categoriesSection.topAnchor.constraint(equalTo: otherHabitsSection.bottomAnchor, constant: 24),
            categoriesSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoriesSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoriesSection.heightAnchor.constraint(equalToConstant: 180),
            categoriesSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            categoriesLabel.topAnchor.constraint(equalTo: categoriesSection.topAnchor),
            categoriesLabel.leadingAnchor.constraint(equalTo: categoriesSection.leadingAnchor, constant: 20),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 16),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: categoriesSection.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: categoriesSection.trailingAnchor),
            categoriesCollectionView.bottomAnchor.constraint(equalTo: categoriesSection.bottomAnchor)
        ])
    }
    
    private func setupAddButton() {
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        view.addSubview(addHabitButton)
        
        NSLayoutConstraint.activate([
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addHabitButton.widthAnchor.constraint(equalToConstant: 60),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCollectionViews() {
        // Categories Collection View
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        
        // Other Habits Collection View
        otherHabitsCollectionView.delegate = self
        otherHabitsCollectionView.dataSource = self
        otherHabitsCollectionView.register(HabitCardCell.self, forCellWithReuseIdentifier: "HabitCardCell")
        
        // Habit Grid Collection View
        habitGridCollectionView.delegate = self
        habitGridCollectionView.dataSource = self
    }
    
    // MARK: - Data & UI Update Methods
    private func updateDateLabel() {
        // Use formatted date - June 5, 2025 (as per your provided date)
        dateLabel.text = "Thursday, June 5"
    }
    
    private func loadHabits() {
        isLoading = true
        updateUI() // Show loading state
        
        HabitService.shared.getHabits { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let habits):
                    print("DEBUG: Successfully fetched \(habits.count) habits")
                    self.allHabits = habits
                    
                    // Filter habits that should be completed today (keep them visible even when completed)
                    self.todayHabits = habits.filter { habit in
                        return habit.shouldCompleteToday()
                    }
                    
                    // Filter habits not for today
                    self.otherHabits = habits.filter { habit in
                        return !habit.shouldCompleteToday()
                    }
                    
                    print("DEBUG: Today habits count: \(self.todayHabits.count)")
                    print("DEBUG: Other habits count: \(self.otherHabits.count)")
                    
                    self.updateProgressRing()
                    self.updateUI()
                    
                case .failure(let error):
                    print("ERROR: Failed to load habits: \(error.localizedDescription)")
                    self.showError(message: "Failed to load your habits")
                }
            }
        }
    }
    
    private func updateProgressRing() {
        // Get habits that should be completed today
        let todaysScheduledHabits = allHabits.filter { $0.shouldCompleteToday() }
        let totalHabits = max(1, todaysScheduledHabits.count) // Avoid division by zero
        let completedHabits = todaysScheduledHabits.filter { $0.isCompletedToday() }.count
        
        let progress = Float(completedHabits) / Float(totalHabits)
        progressRingView.setProgress(progress, animated: true)
        
        // Update summary description text with more intuitive text
        if todaysScheduledHabits.isEmpty {
            summaryDescriptionLabel.text = "No habits scheduled for today.\nTap + to add a new habit."
        } else if completedHabits == totalHabits {
            summaryDescriptionLabel.text = "You've completed all habits for today! 🎉\n\(completedHabits)/\(totalHabits) completed"
        } else {
            let remaining = totalHabits - completedHabits
            summaryDescriptionLabel.text = "\(completedHabits) of \(totalHabits) completed today.\n\(remaining) remaining for today."
        }
    }
    
    private func updateUI() {
        // Reset views
        todayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if isLoading {
            // Show loading skeleton cells
            emptyStateView.isHidden = true
            todayStackView.isHidden = false
            habitGridCollectionView.isHidden = true
            
            for _ in 0..<3 {
                let skeletonView = HabitItemSkeletonView()
                todayStackView.addArrangedSubview(skeletonView)
            }
            
            categoriesCollectionView.reloadData()
            otherHabitsCollectionView.reloadData()
            return
        }
        
        // Check if we have habits to show for today
        if todayHabits.isEmpty {
            // Show empty state
            emptyStateView.isHidden = false
            todayStackView.isHidden = true
            habitGridCollectionView.isHidden = true
            
            // Fix height for empty state
            if todaySection.constraints.contains(where: { $0.firstAttribute == .height }) {
                let constraints = todaySection.constraints.filter { $0.firstAttribute == .height }
                constraints.forEach { $0.isActive = false }
            }
            todaySection.heightAnchor.constraint(equalToConstant: 200).isActive = true
            
        } else if todayHabits.count <= maxStackViewHabits {
            // Few habits - show as stack view
            emptyStateView.isHidden = true
            todayStackView.isHidden = false
            habitGridCollectionView.isHidden = true
            
            // Remove height constraint if it exists
            todaySection.constraints.filter { $0.firstAttribute == .height }.forEach { $0.isActive = false }
            
            // Add habit views to stack
            for habit in todayHabits {
                let habitView = HealthStyleHabitView(habit: habit)
                habitView.delegate = self
                todayStackView.addArrangedSubview(habitView)
                
                // Health app style cards are larger
                habitView.heightAnchor.constraint(equalToConstant: 90).isActive = true
            }
            
        } else {
            // Many habits - show as grid
            emptyStateView.isHidden = true
            todayStackView.isHidden = true
            habitGridCollectionView.isHidden = false
            
            // Calculate grid height based on number of rows needed
            let itemsPerRow = 3 // Changed from 4 to 3 items per row for better visibility
            let numberOfItems = todayHabits.count
            let numberOfRows = Int(ceil(Double(numberOfItems) / Double(itemsPerRow)))
            let rowHeight = habitGridFlowLayout.itemSize.height
            let spacing = habitGridFlowLayout.minimumLineSpacing
            let totalHeight = CGFloat(numberOfRows) * rowHeight + CGFloat(max(0, numberOfRows - 1)) * spacing + 16
            
            // Set section height with more padding
            todaySection.constraints.filter { $0.firstAttribute == .height }.forEach { $0.isActive = false }
            todaySection.heightAnchor.constraint(equalToConstant: totalHeight + 60).isActive = true
            
            // Update grid layout
            habitGridFlowLayout.invalidateLayout()
            habitGridCollectionView.reloadData()
        }
        
        // Set empty state for other habits collection view if needed
        if otherHabits.isEmpty && !isLoading {
            let emptyLabel = UILabel()
            emptyLabel.text = "No other habits"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            otherHabitsCollectionView.backgroundView = emptyLabel
        } else {
            otherHabitsCollectionView.backgroundView = nil
        }
        
        categoriesCollectionView.reloadData()
        otherHabitsCollectionView.reloadData()
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
    
    @objc private func seeAllTodayHabits() {
        // Navigate to a view showing all habits in card format
        let allHabitsVC = AllHabitsViewController(habits: todayHabits, title: "Today's Habits")
        navigationController?.pushViewController(allHabitsVC, animated: true)
    }
}

// MARK: - Collection View Delegate & DataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return 4 // Fixed number of categories
        } else if collectionView == otherHabitsCollectionView {
            if isLoading {
                return 3 // Show skeleton cells when loading
            } else if otherHabits.isEmpty {
                return 0 // Don't show any cells when there are no other habits
            } else {
                return otherHabits.count
            }
        } else if collectionView == habitGridCollectionView {
            return todayHabits.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            let categories = ["Fitness", "Mindfulness", "Learning", "Productivity"]
            let icons = ["figure.walk", "brain.head.profile", "book.fill", "checklist"]
            let colors: [UIColor] = [.systemGreen, .systemPurple, .systemOrange, .systemBlue]
            
            cell.configure(title: categories[indexPath.item],
                          iconName: icons[indexPath.item],
                          color: colors[indexPath.item])
            return cell
            
        } else if collectionView == otherHabitsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! HabitCardCell
            
            if isLoading {
                cell.showSkeleton()
            } else if indexPath.item < otherHabits.count {
                let habit = otherHabits[indexPath.item]
                cell.configure(with: habit)
            }
            return cell
            
        } else if collectionView == habitGridCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompactHabitCell", for: indexPath) as! CompactHabitCell
            
            if indexPath.item < todayHabits.count {
                let habit = todayHabits[indexPath.item]
                cell.configure(with: habit)
                cell.delegate = self
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == otherHabitsCollectionView && !isLoading && indexPath.item < otherHabits.count {
            let habitDetailVC = HabitDetailViewController(habit: otherHabits[indexPath.item])
            navigationController?.pushViewController(habitDetailVC, animated: true)
        } else if collectionView == habitGridCollectionView && indexPath.item < todayHabits.count {
            let habit = todayHabits[indexPath.item]
            if !habit.isCompletedToday() {
                didTapCompleteButton(for: habit)
            } else {
                // If already completed, show detail view
                let habitDetailVC = HabitDetailViewController(habit: habit)
                navigationController?.pushViewController(habitDetailVC, animated: true)
            }
        }
    }
}

// MARK: - HabitCardViewDelegate
extension HomeViewController: HabitCardViewDelegate {
    func didTapCompleteButton(for habit: Habit) {
        print("DEBUG: Completing habit: \(habit.title)")
        
        // Show haptic feedback to confirm the tap
        HapticFeedback.success()
        
        // Only proceed if the habit isn't already completed today
        if !habit.isCompletedToday() {
            // Always call the service to complete the habit
            HabitService.shared.completeHabit(habitId: habit.id) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updatedHabit):
                        print("DEBUG: Successfully completed habit in Firebase")
                        
                        // Update allHabits array with new data
                        if let index = self.allHabits.firstIndex(where: { $0.id == habit.id }) {
                            self.allHabits[index] = updatedHabit
                        }
                        
                        // Update todayHabits array with new data
                        if let index = self.todayHabits.firstIndex(where: { $0.id == habit.id }) {
                            self.todayHabits[index] = updatedHabit
                        }
                        
                        // Update UI
                        self.updateProgressRing()
                        self.updateUI()
                        
                    case .failure(let error):
                        print("ERROR: Failed to complete habit: \(error.localizedDescription)")
                        self.showError(message: "Failed to mark habit as completed")
                    }
                }
            }
        } else {
            print("DEBUG: Habit already completed today")
        }
    }
}

// MARK: - CompactHabitCellDelegate
extension HomeViewController: CompactHabitCellDelegate {
    func didTapCompactHabitCell(_ cell: CompactHabitCell, habit: Habit) {
        didTapCompleteButton(for: habit)
    }
}

// MARK: - AddHabitViewControllerDelegate
extension HomeViewController: AddHabitViewControllerDelegate {
    func didAddHabit() {
        loadHabits()
    }
}

// MARK: - UI Helper Classes
// New CompactHabitCell for Grid View
class CompactHabitCell: UICollectionViewCell {
    private let containerView = UIView()
    private let iconLabel = UILabel()
    private let completionIndicator = UIView()
    
    private var habit: Habit?
    weak var delegate: CompactHabitCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        contentView.addSubview(containerView)
        
        // Add gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 12
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemBlue.withAlphaComponent(0.8).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        containerView.layer.addSublayer(gradientLayer)
        
        // Icon Label (emoji)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        contentView.addSubview(iconLabel)
        
        // Completion indicator
        completionIndicator.translatesAutoresizingMaskIntoConstraints = false
        completionIndicator.backgroundColor = .systemGreen
        completionIndicator.layer.cornerRadius = 6
        completionIndicator.isHidden = true
        contentView.addSubview(completionIndicator)
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            completionIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            completionIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            completionIndicator.widthAnchor.constraint(equalToConstant: 12),
            completionIndicator.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient layer frame
        if let gradientLayer = containerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = containerView.bounds
        }
    }
    
    func configure(with habit: Habit) {
        self.habit = habit
        
        // Get icon emoji for SF Symbol name
        let symbolToEmoji: [String: String] = [
            "figure.walk": "🚶",
            "drop.fill": "💧",
            "book.fill": "📚",
            "bed.double.fill": "🛌",
            "pills.fill": "💊",
            "fork.knife": "🍽️",
            "heart.fill": "❤️",
            "brain.head.profile": "🧠",
            "moon.fill": "🌙",
            "pencil": "✏️",
            "checkmark.circle": "✅",
            "checkmark.circle.fill": "✅",
            "calendar": "📅",
            "star.fill": "⭐",
            "leaf.fill": "🍃",
            "flame.fill": "🔥",
            "pawprint.fill": "🐾",
            "graduationcap.fill": "🎓",
            "bicycle": "🚲",
            "music.note": "🎵",
            "doc.fill": "📄",
            "building.2.fill": "🏢",
            "person.fill": "👤",
            "person.2.fill": "👥",
            "house.fill": "🏠",
            "gift.fill": "🎁",
            "creditcard.fill": "💳",
            "bolt.fill": "⚡",
            "sun.max.fill": "☀️",
            "cloud.fill": "☁️",
            "sparkles": "✨",
            "cart.fill": "🛒",
            "hammer.fill": "🔨",
            "pin.fill": "📌"
        ]
        
        // Set emoji or default to system icon
        iconLabel.text = symbolToEmoji[habit.icon] ?? "📌"
        
        // Set gradient colors based on habit color
        let habitColor = ColorHelper.color(fromHex: habit.color)
        if let gradientLayer = containerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.colors = [
                habitColor.cgColor,
                habitColor.withAlphaComponent(0.8).cgColor
            ]
        }
        
        // Update completion indicator
        completionIndicator.isHidden = !habit.isCompletedToday()
    }
    
    @objc private func cellTapped() {
        guard let habit = habit else { return }
        
        // Show tap animation
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        
        // Call delegate for completion
        delegate?.didTapCompactHabitCell(self, habit: habit)
    }
}

// Protocol for compact cell delegate
protocol CompactHabitCellDelegate: AnyObject {
    func didTapCompactHabitCell(_ cell: CompactHabitCell, habit: Habit)
}

// Category Cell
class CategoryCell: UICollectionViewCell {
    private let containerView = UIView()
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Cell styling
        contentView.backgroundColor = .clear
        
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 14
        contentView.addSubview(containerView)
        
        // Icon View
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.layer.cornerRadius = 20
        containerView.addSubview(iconView)
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconView.addSubview(iconImageView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, iconName: String, color: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        iconView.backgroundColor = color
    }
}

// Health app style Habit View
class HealthStyleHabitView: UIView {
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
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 14
        addSubview(containerView)
        
        // Icon Container
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 22
        containerView.addSubview(iconContainer)
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconContainer.addSubview(iconImageView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        // Streak
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.font = UIFont.systemFont(ofSize: 14)
        streakLabel.textColor = .secondaryLabel
        containerView.addSubview(streakLabel)
        
        // Complete Button - Larger size with better touch area
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        completeButton.isUserInteractionEnabled = true
        containerView.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
            
            streakLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            streakLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            streakLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
            
            completeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 60), // Larger width for better tap area
            completeButton.heightAnchor.constraint(equalToConstant: 60) // Larger height for better tap area
        ])
        
        // Make the entire view tappable to complete the habit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        configure()
    }
    
    private func configure() {
        // Set color
        iconContainer.backgroundColor = ColorHelper.color(fromHex: habit.color)
        
        // Set icon
        iconImageView.image = UIImage(systemName: habit.icon)
        
        // Set text
        titleLabel.text = habit.title
        
        if habit.streak > 0 {
            streakLabel.text = "🔥 \(habit.streak) day streak"
        } else {
            streakLabel.text = "Start your streak today!"
        }
        
        // Configure button - show checkmark if completed
        let isCompleted = habit.isCompletedToday()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "circle", withConfiguration: config)
        completeButton.setImage(image, for: .normal)
        completeButton.tintColor = isCompleted ? .systemGreen : .systemBlue
    }
    
    @objc private func completeButtonTapped() {
        print("DEBUG: Complete button tapped for habit: \(habit.title)")
        if !habit.isCompletedToday() {
            delegate?.didTapCompleteButton(for: habit)
        }
    }
    
    @objc private func viewTapped() {
        // When tapping anywhere on the container, consider it as tapping the complete button
        if !habit.isCompletedToday() {
            // Animate the button tap
            UIView.animate(withDuration: 0.1, animations: {
                self.completeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.completeButton.transform = .identity
                }
            }
            
            // Call the delegate
            delegate?.didTapCompleteButton(for: habit)
        }
    }
}

// "See All" view controller to show all habits in card format
class AllHabitsViewController: UIViewController {
    
    private let habitsTableView = UITableView()
    private let habits: [Habit]
    private let screenTitle: String
    
    init(habits: [Habit], title: String) {
        self.habits = habits
        self.screenTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = screenTitle
        view.backgroundColor = .systemBackground
        
        // Configure table view
        habitsTableView.translatesAutoresizingMaskIntoConstraints = false
        habitsTableView.delegate = self
        habitsTableView.dataSource = self
        habitsTableView.separatorStyle = .none
        habitsTableView.showsVerticalScrollIndicator = false
        habitsTableView.register(HabitCardTableViewCell.self, forCellReuseIdentifier: "HabitCardTableViewCell")
        view.addSubview(habitsTableView)
        
        NSLayoutConstraint.activate([
            habitsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            habitsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            habitsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            habitsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// Table view methods for "See All" view
extension AllHabitsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCardTableViewCell", for: indexPath) as! HabitCardTableViewCell
        let habit = habits[indexPath.row]
        cell.configure(with: habit)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// HabitCardViewDelegate implementation for AllHabitsViewController
extension AllHabitsViewController: HabitCardViewDelegate {
    func didTapCompleteButton(for habit: Habit) {
        // Show haptic feedback
        HapticFeedback.success()
        
        // Update Firebase
        if !habit.isCompletedToday() {
            HabitService.shared.completeHabit(habitId: habit.id) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("DEBUG: Successfully completed habit in See All view")
                        self.habitsTableView.reloadData()
                        
                    case .failure(let error):
                        print("ERROR: Failed to complete habit: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "Error", message: "Failed to mark habit as completed", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

// Custom table view cell for the "See All" view
class HabitCardTableViewCell: UITableViewCell {
    private var habitView: HealthStyleHabitView?
    weak var delegate: HabitCardViewDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with habit: Habit) {
        // Remove any existing habit view
        habitView?.removeFromSuperview()
        
        // Create and add a new habit view
        habitView = HealthStyleHabitView(habit: habit)
        habitView?.delegate = delegate
        
        if let habitView = habitView {
            habitView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(habitView)
            
            NSLayoutConstraint.activate([
                habitView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                habitView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                habitView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                habitView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }
    }
}

// Health-style Floating Button
class HealthStyleFloatingButton: UIButton {
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
        
        // Add plus icon
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        // Add tap feedback
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}

// Empty State View
class EmptyStateView: UIView {
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    
    init(message: String) {
        super.init(frame: .zero)
        setupUI(with: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(with message: String) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        addSubview(containerView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        imageView.image = UIImage(systemName: "calendar.badge.plus")
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        imageView.preferredSymbolConfiguration = config
        containerView.addSubview(imageView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .systemGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

// Skeleton loading view
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
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 14
        addSubview(containerView)
        
        // Icon placeholder
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = .systemGray5
        iconView.layer.cornerRadius = 22
        containerView.addSubview(iconView)
        
        // Title placeholder
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .systemGray5
        titleView.layer.cornerRadius = 6
        containerView.addSubview(titleView)
        
        // Subtitle placeholder
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.backgroundColor = .systemGray5
        subtitleView.layer.cornerRadius = 4
        containerView.addSubview(subtitleView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            titleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            titleView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleView.widthAnchor.constraint(equalToConstant: 140),
            titleView.heightAnchor.constraint(equalToConstant: 18),
            
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            subtitleView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            subtitleView.widthAnchor.constraint(equalToConstant: 90),
            subtitleView.heightAnchor.constraint(equalToConstant: 14)
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

// Helper for color conversions


