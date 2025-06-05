import UIKit

class TasksViewController: UIViewController {
    
    // UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let filterSegmentedControl = UISegmentedControl(items: ["All", "Active", "Completed"])
    private let tableView = UITableView()
    private let emptyStateView = EmptyStateView(message: "No habits yet. Add one to get started!")
    private let addButton = FloatingActionButton()
    
    // Data
    private var habits: [Habit] = []
    private var filteredHabits: [Habit] = []
    private var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHabits()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        view.addSubview(headerView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = "My Habits"
        headerView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .white.withAlphaComponent(0.8)
        subtitleLabel.text = "Track and manage your progress"
        headerView.addSubview(subtitleLabel)
        
        // Filter Segmented Control
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.backgroundColor = .white
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        view.addSubview(filterSegmentedControl)
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        view.addSubview(tableView)
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        // Add Button
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            filterSegmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: 40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Apply gradient to header view on next layout pass
        DispatchQueue.main.async {
            self.headerView.applyGradient(
                colors: [
                    UIColor(hex: "#4F46E5") ?? .systemBlue,
                    UIColor(hex: "#8B5CF6") ?? .systemIndigo
                ],
                startPoint: CGPoint(x: 0, y: 0),  // Top left
                endPoint: CGPoint(x: 1, y: 1)     // Bottom right
            )
            
            // Add shadow to segmented control
            self.filterSegmentedControl.layer.cornerRadius = 8
            self.filterSegmentedControl.clipsToBounds = true
            self.filterSegmentedControl.layer.masksToBounds = false
            self.filterSegmentedControl.layer.shadowColor = UIColor.black.cgColor
            self.filterSegmentedControl.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.filterSegmentedControl.layer.shadowOpacity = 0.1
            self.filterSegmentedControl.layer.shadowRadius = 4
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskHabitCell.self, forCellReuseIdentifier: "TaskHabitCell")
    }
    
    private func loadHabits() {
        isLoading = true
        tableView.reloadData()
        
        HabitService.shared.getHabits { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let habits):
                    self.habits = habits
                    
                    // Apply initial filter
                    self.applyFilter()
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func applyFilter() {
        switch filterSegmentedControl.selectedSegmentIndex {
        case 0: // All
            filteredHabits = habits
        case 1: // Active
            filteredHabits = habits.filter { !$0.isCompletedToday() }
        case 2: // Completed
            filteredHabits = habits.filter { $0.isCompletedToday() }
        default:
            filteredHabits = habits
        }
        
        // Sort habits by completion status
        if filterSegmentedControl.selectedSegmentIndex == 0 {
            filteredHabits.sort { !$0.isCompletedToday() && $1.isCompletedToday() }
        }
        
        // Show empty state if needed
        emptyStateView.isHidden = !filteredHabits.isEmpty
        
        // Update table
        tableView.reloadData()
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func filterChanged() {
        applyFilter()
    }
    
    @objc private func addHabitTapped() {
        let addHabitVC = AddHabitViewController()
        addHabitVC.delegate = self
        let navController = UINavigationController(rootViewController: addHabitVC)
        present(navController, animated: true)
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 5 // Skeleton cells
        }
        return filteredHabits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskHabitCell", for: indexPath) as? TaskHabitCell else {
            return UITableViewCell()
        }
        
        if isLoading {
            cell.showSkeleton()
            return cell
        }
        
        let habit = filteredHabits[indexPath.row]
        cell.configure(with: habit)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let habit = filteredHabits[indexPath.row]
        let habitDetailVC = HabitDetailViewController(habit: habit)
        habitDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(habitDetailVC, animated: true)
    }
}

// MARK: - TaskHabitCellDelegate
extension TasksViewController: TaskHabitCellDelegate {
    func didTapCompleteButton(for habit: Habit) {
        HabitService.shared.completeHabit(habitId: habit.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Reload data to refresh the UI
                    self.loadHabits()
                    
                    // Show a small feedback
                    if let index = self.habits.firstIndex(where: { $0.id == habit.id }) {
                        let habit = self.habits[index]
                        if habit.streak > 0 && habit.streak % 5 == 0 {
                            // For milestone streaks, show confetti effect
                            let confettiView = ConfettiView(frame: self.view.bounds)
                            self.view.addSubview(confettiView)
                            confettiView.startConfetti()
                            
                            // Remove confetti after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                confettiView.stopConfetti()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    confettiView.removeFromSuperview()
                                }
                            }
                        } else {
                            // For regular streaks, provide haptic feedback
                            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                            feedbackGenerator.prepare()
                            feedbackGenerator.impactOccurred()
                        }
                    }
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - AddHabitViewControllerDelegate
extension TasksViewController: AddHabitViewControllerDelegate {
    func didAddHabit() {
        loadHabits()
    }
}
