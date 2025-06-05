import UIKit

class HomeViewController: UIViewController {
    
    // UI Components
    private let headerView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let dateLabel = UILabel()
    private let streakView = StreakView()
    private let progressRingView = CircularProgressView(frame: .zero, lineWidth: 15)
    private let todayTitleView = SectionHeaderView(title: "Today's Focus")
    private let todayStackView = UIStackView()
    private let upcomingTitleView = SectionHeaderView(title: "Upcoming")
    private let habitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: 160, height: 180)
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
        loadHabits()
        updateDateLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Apply gradient to header view with non-ambiguous colors
        headerView.applyGradient(
            colors: [
                .systemBlue,
                .systemIndigo
            ],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1)
        )
    }
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.layer.cornerRadius = 0
        view.addSubview(headerView)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemBackground
        scrollView.addSubview(contentView)
        
        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        dateLabel.textColor = .white
        headerView.addSubview(dateLabel)
        
        // Streak View
        streakView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(streakView)
        
        // Progress Ring
        progressRingView.translatesAutoresizingMaskIntoConstraints = false
        progressRingView.progressColor = .white
        progressRingView.trackColor = UIColor.white.withAlphaComponent(0.3)
        headerView.addSubview(progressRingView)
        
        // Today Section Title
        todayTitleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(todayTitleView)
        
        // Today Stack View
        todayStackView.translatesAutoresizingMaskIntoConstraints = false
        todayStackView.axis = .vertical
        todayStackView.spacing = 12
        todayStackView.distribution = .fillEqually
        contentView.addSubview(todayStackView)
        
        // Upcoming Section Title
        upcomingTitleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(upcomingTitleView)
        
        // Habits Collection View
        habitsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        habitsCollectionView.backgroundColor = .clear
        habitsCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(habitsCollectionView)
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        contentView.addSubview(emptyStateView)
        
        // Add Habit Button
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        view.addSubview(addHabitButton)
        
        // Layout Constraints
        let headerHeight: CGFloat = 180
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            dateLabel.trailingAnchor.constraint(equalTo: progressRingView.leadingAnchor, constant: -20),
            
            streakView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            streakView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            streakView.widthAnchor.constraint(equalToConstant: 120),
            streakView.heightAnchor.constraint(equalToConstant: 60),
            
            progressRingView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 70),
            progressRingView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            progressRingView.widthAnchor.constraint(equalToConstant: 80),
            progressRingView.heightAnchor.constraint(equalToConstant: 80),
            
            todayTitleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            todayTitleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            todayTitleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            todayStackView.topAnchor.constraint(equalTo: todayTitleView.bottomAnchor, constant: 16),
            todayStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            todayStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            upcomingTitleView.topAnchor.constraint(equalTo: todayStackView.bottomAnchor, constant: 30),
            upcomingTitleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingTitleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            habitsCollectionView.topAnchor.constraint(equalTo: upcomingTitleView.bottomAnchor, constant: 16),
            habitsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            habitsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            habitsCollectionView.heightAnchor.constraint(equalToConstant: 200),
            habitsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            emptyStateView.topAnchor.constraint(equalTo: todayTitleView.bottomAnchor, constant: 30),
            emptyStateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
            
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addHabitButton.widthAnchor.constraint(equalToConstant: 60),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Update welcome label with username
        if let user = AuthService.shared.currentUser {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            dateLabel.text = formatter.string(from: Date())
        }
        
        // Set initial progress (will be updated when habits load)
        progressRingView.setProgress(0, animated: false)
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
        isLoading = true
        habitsCollectionView.reloadData()
        
        // Clear todayStackView before adding new habit cards
        todayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        HabitService.shared.getHabits { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let habits):
                    self.allHabits = habits
                    
                    // Filter habits for today based on frequency
                    self.todayHabits = habits.filter { habit in
                        switch habit.frequency {
                        case .daily:
                            return true
                        case .weekly:
                            let calendar = Calendar.current
                            let weekday = calendar.component(.weekday, from: Date())
                            let startWeekday = calendar.component(.weekday, from: habit.startDate)
                            return weekday == startWeekday
                        case .monthly:
                            let calendar = Calendar.current
                            let day = calendar.component(.day, from: Date())
                            let startDay = calendar.component(.day, from: habit.startDate)
                            return day == startDay
                        case .custom:
                            // For simplicity, we'll show custom habits every day
                            return true
                        }
                    }
                    
                    // Add habit cards to today stack view
                    self.updateTodayHabitsUI()
                    
                    // Show empty state if needed
                    self.emptyStateView.isHidden = !self.todayHabits.isEmpty
                    
                    // Update collection view
                    self.habitsCollectionView.reloadData()
                    
                    // Update progress ring
                    self.updateProgressRing()
                    
                    // Update streak view
                    self.updateStreakView()
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateTodayHabitsUI() {
        // Sort habits by completion status (incomplete first)
        let sortedHabits = todayHabits.sorted { !$0.isCompletedToday() && $1.isCompletedToday() }
        
        for habit in sortedHabits {
            let habitCard = HabitCardView(habit: habit)
            habitCard.delegate = self
            todayStackView.addArrangedSubview(habitCard)
            
            // Set fixed height
            habitCard.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }
    }
    
    private func updateProgressRing() {
        if todayHabits.isEmpty {
            progressRingView.setProgress(0, animated: true)
            return
        }
        
        let completedCount = todayHabits.filter { $0.isCompletedToday() }.count
        let progress = Float(completedCount) / Float(todayHabits.count)
        
        progressRingView.setProgress(progress, animated: true)
    }
    
    private func updateStreakView() {
        let totalStreaks = allHabits.reduce(0) { $0 + $1.streak }
        streakView.configure(streakCount: totalStreaks)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func showStreakCelebration(streak: Int) {
        let confettiView = ConfettiView(frame: view.bounds)
        view.addSubview(confettiView)
        confettiView.startConfetti()
        
        // Create alert with custom view
        let alertController = UIAlertController(
            title: "🎉 Achievement Unlocked!",
            message: "You've completed this habit \(streak) times in a row. Keep up the amazing work!",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Thanks!", style: .default) { _ in
            // Stop confetti after alert is dismissed
            confettiView.stopConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                confettiView.removeFromSuperview()
            }
        })
        present(alertController, animated: true)
    }
    
    @objc private func addHabitTapped() {
        let addHabitVC = AddHabitViewController()
        addHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: addHabitVC)
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 3 // Skeleton cells
        }
        return allHabits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as? HabitCardCell else {
            return UICollectionViewCell()
        }
        
        if isLoading {
            cell.showSkeleton()
            return cell
        }
        
        if indexPath.row < allHabits.count {
            let habit = allHabits[indexPath.row]
            cell.configure(with: habit)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let habit = allHabits[indexPath.row]
        let habitDetailVC = HabitDetailViewController(habit: habit)
        navigationController?.pushViewController(habitDetailVC, animated: true)
    }
}

// MARK: - HabitCardViewDelegate
extension HomeViewController: HabitCardViewDelegate {
    func didTapCompleteButton(for habit: Habit) {
        HabitService.shared.completeHabit(habitId: habit.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let updatedHabit):
                    // Update UI
                    self.loadHabits()
                    
                    // Show streak celebration for milestone streaks
                    if updatedHabit.streak > 0 && updatedHabit.streak % 5 == 0 {
                        self.showStreakCelebration(streak: updatedHabit.streak)
                    }
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - AddHabitViewControllerDelegate
extension HomeViewController: AddHabitViewControllerDelegate {
    func didAddHabit() {
        loadHabits()
    }
}
