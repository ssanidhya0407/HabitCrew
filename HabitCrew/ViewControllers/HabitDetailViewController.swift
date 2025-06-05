//
//  HabitDetailViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class HabitDetailViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statsStackView = UIStackView()
    private let buddiesLabel = UILabel()
    private let buddiesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let historyLabel = UILabel()
    private let historyTableView = UITableView()
    
    // Data
    private let habit: Habit
    private var buddies: [User] = []
    
    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHabitData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.title = "Habit Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(hex: habit.color) ?? .systemBlue
        contentView.addSubview(headerView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.image = UIImage(systemName: habit.icon)
        headerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = habit.title
        headerView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = habit.description ?? "No description"
        headerView.addSubview(descriptionLabel)
        
        // Stats Stack View
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 20
        contentView.addSubview(statsStackView)
        
        // Add stat views
        let streakStatView = createStatView(value: "\(habit.streak)", label: "Day Streak")
        let completionsStatView = createStatView(value: "\(habit.completedDates.count)", label: "Completions")
        let startedStatView = createStatView(
            value: habit.startDate.formatted(.dateTime.month().day()),
            label: "Started"
        )
        
        statsStackView.addArrangedSubview(streakStatView)
        statsStackView.addArrangedSubview(completionsStatView)
        statsStackView.addArrangedSubview(startedStatView)
        
        // Buddies Label
        buddiesLabel.translatesAutoresizingMaskIntoConstraints = false
        buddiesLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        buddiesLabel.text = "Buddies"
        contentView.addSubview(buddiesLabel)
        
        // Buddies Collection View
        let buddiesLayout = UICollectionViewFlowLayout()
        buddiesLayout.scrollDirection = .horizontal
        buddiesLayout.itemSize = CGSize(width: 70, height: 90)
        buddiesLayout.minimumInteritemSpacing = 10
        
        buddiesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        buddiesCollectionView.collectionViewLayout = buddiesLayout
        buddiesCollectionView.backgroundColor = .systemBackground
        buddiesCollectionView.showsHorizontalScrollIndicator = false
        buddiesCollectionView.register(BuddyCollectionViewCell.self, forCellWithReuseIdentifier: "BuddyCollectionCell")
        buddiesCollectionView.delegate = self
        buddiesCollectionView.dataSource = self
        contentView.addSubview(buddiesCollectionView)
        
        // History Label
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        historyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        historyLabel.text = "History"
        contentView.addSubview(historyLabel)
        
        // History Table View
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.backgroundColor = .systemBackground
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        historyTableView.isScrollEnabled = false
        contentView.addSubview(historyTableView)
        
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
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            
            iconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStackView.heightAnchor.constraint(equalToConstant: 70),
            
            buddiesLabel.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 30),
            buddiesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            buddiesCollectionView.topAnchor.constraint(equalTo: buddiesLabel.bottomAnchor, constant: 10),
            buddiesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buddiesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buddiesCollectionView.heightAnchor.constraint(equalToConstant: 90),
            
            historyLabel.topAnchor.constraint(equalTo: buddiesCollectionView.bottomAnchor, constant: 30),
            historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            historyTableView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 10),
            historyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            historyTableView.heightAnchor.constraint(equalToConstant: 300),
            historyTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createStatView(value: String, label: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 10
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.text = value
        valueLabel.textAlignment = .center
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.text = label
        textLabel.textColor = .secondaryLabel
        textLabel.textAlignment = .center
        
        containerView.addSubview(valueLabel)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        return containerView
    }
    
    private func loadHabitData() {
        // Load buddies data if available
        if let buddyIds = habit.buddyIds, !buddyIds.isEmpty {
            loadBuddies(buddyIds: buddyIds)
        }
        
        // Refresh table view for history
        historyTableView.reloadData()
    }
    
    private func loadBuddies(buddyIds: [String]) {
        // In a real app, you would load the buddy data from the service
        // For now, we'll just create some placeholder data
        buddies = []
        buddiesCollectionView.reloadData()
    }
    
    @objc private func editTapped() {
        let editHabitVC = EditHabitViewController(habit: habit)
        navigationController?.pushViewController(editHabitVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension HabitDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if buddies.isEmpty {
            return 1 // "No buddies yet" cell
        }
        return buddies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuddyCollectionCell", for: indexPath) as? BuddyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if buddies.isEmpty {
            cell.configureAsEmpty()
        } else {
            let buddy = buddies[indexPath.item]
            cell.configure(with: buddy)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HabitDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(habit.completedDates.count, 10) // Show max 10 recent completions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        
        // Sort dates in descending order
        let sortedDates = habit.completedDates.sorted(by: >)
        
        if indexPath.row < sortedDates.count {
            let date = sortedDates[indexPath.row]
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            cell.textLabel?.text = formatter.string(from: date)
            cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
            cell.imageView?.tintColor = .systemGreen
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Completions"
    }
}