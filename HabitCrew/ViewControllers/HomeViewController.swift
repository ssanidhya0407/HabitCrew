//
//  HomeViewController.swift
//  HabitCrew
//
//  Redesigned on 2025-06-06
//  Modern Habits Screen with Firebase integration
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header components
    private let headerView = UIView()
    private let greetingLabel = UILabel()
    private let dateLabel = UILabel()
    private let profileButton = UIButton()

    // Mini calendar
    private let calendarCard = BaseCard()
    private let miniCalendar = MiniCalendarView()

    // Summary section
    private let summaryCard = GradientCard(gradientStyle: .mintPurple)
    private let circularProgress = CircularProgressView(frame: .zero, lineWidth: 12)
    private let progressTitleLabel = UILabel()
    private let progressDescriptionLabel = UILabel()

    // Today's Habits section
    private let todaySection = UIView()
    private let todaySectionHeader = UIView()
    private let todayTitleLabel = UILabel()
    private let todaySeeAllButton = UIButton(type: .system)

    // Habits collection view
    private let habitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = DesignTokens.Spacing.medium
        layout.minimumInteritemSpacing = DesignTokens.Spacing.medium
        layout.sectionInset = UIEdgeInsets(
            top: DesignTokens.Spacing.medium,
            left: DesignTokens.Spacing.medium,
            bottom: DesignTokens.Spacing.medium,
            right: DesignTokens.Spacing.medium
        )
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Empty state
    private let emptyStateView = EmptyStateView.noHabits()

    // Floating action button
    private let addHabitButton: FloatingActionButton = {
        let button = FloatingActionButton()
        button.configureAsPrimary()
        return button
    }()

    // Data
    private var todayHabits: [Habit] = []
    private var allHabits: [Habit] = []
    private var isLoading = true
    private var selectedDate = Date()

    // MARK: - Lifecycle

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Animate components in
        animateComponentsIn()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = .backgroundPrimary

        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        setupHeader()
        setupMiniCalendar()
        setupSummaryCard()
        setupTodaySection()
        setupFloatingButton()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        contentView.addSubview(headerView)

        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.font = DesignTokens.Font.headline
        greetingLabel.textColor = .textPrimary
        greetingLabel.text = "Welcome Back!"
        headerView.addSubview(greetingLabel)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = DesignTokens.Font.caption
        dateLabel.textColor = .textSecondary
        dateLabel.text = "June 6, 2025"
        headerView.addSubview(dateLabel)

        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        profileButton.tintColor = .accentMint
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        headerView.addSubview(profileButton)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignTokens.Spacing.medium),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.medium),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.medium),

            greetingLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            greetingLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),

            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: DesignTokens.Spacing.small),
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            profileButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupMiniCalendar() {
        calendarCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarCard)

        miniCalendar.translatesAutoresizingMaskIntoConstraints = false
        miniCalendar.delegate = self
        calendarCard.addSubview(miniCalendar)

        NSLayoutConstraint.activate([
            calendarCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: DesignTokens.Spacing.large),
            calendarCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.medium),
            calendarCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.medium),
            calendarCard.heightAnchor.constraint(equalToConstant: 200),

            miniCalendar.topAnchor.constraint(equalTo: calendarCard.topAnchor),
            miniCalendar.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor),
            miniCalendar.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor),
            miniCalendar.bottomAnchor.constraint(equalTo: calendarCard.bottomAnchor)
        ])
    }

    private func setupSummaryCard() {
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryCard)

        circularProgress.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.addSubview(circularProgress)

        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressTitleLabel.font = DesignTokens.Font.headline
        progressTitleLabel.textColor = .white
        progressTitleLabel.text = "Today's Progress"
        summaryCard.addSubview(progressTitleLabel)

        progressDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        progressDescriptionLabel.font = DesignTokens.Font.body
        progressDescriptionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        progressDescriptionLabel.numberOfLines = 2
        progressDescriptionLabel.text = "Stay consistent and build your habits!"
        summaryCard.addSubview(progressDescriptionLabel)

        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: DesignTokens.Spacing.large),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.medium),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.medium),
            summaryCard.heightAnchor.constraint(equalToConstant: 160),

            circularProgress.centerYAnchor.constraint(equalTo: summaryCard.centerYAnchor),
            circularProgress.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: DesignTokens.Spacing.large),
            circularProgress.widthAnchor.constraint(equalToConstant: 80),
            circularProgress.heightAnchor.constraint(equalToConstant: 80),

            progressTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: DesignTokens.Spacing.large),
            progressTitleLabel.leadingAnchor.constraint(equalTo: circularProgress.trailingAnchor, constant: DesignTokens.Spacing.medium),
            progressTitleLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -DesignTokens.Spacing.large),

            progressDescriptionLabel.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: DesignTokens.Spacing.small),
            progressDescriptionLabel.leadingAnchor.constraint(equalTo: circularProgress.trailingAnchor, constant: DesignTokens.Spacing.medium),
            progressDescriptionLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -DesignTokens.Spacing.large)
        ])
    }

    private func setupTodaySection() {
        todaySection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(todaySection)

        todaySectionHeader.translatesAutoresizingMaskIntoConstraints = false
        todaySection.addSubview(todaySectionHeader)

        todayTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        todayTitleLabel.font = DesignTokens.Font.headline
        todayTitleLabel.textColor = .textPrimary
        todayTitleLabel.text = "Today's Habits"
        todaySectionHeader.addSubview(todayTitleLabel)

        todaySeeAllButton.translatesAutoresizingMaskIntoConstraints = false
        todaySeeAllButton.setTitle("See All", for: .normal)
        todaySeeAllButton.setTitleColor(.accentMint, for: .normal)
        todaySeeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
        todaySectionHeader.addSubview(todaySeeAllButton)

        habitsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        todaySection.addSubview(habitsCollectionView)

        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        todaySection.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            todaySection.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: DesignTokens.Spacing.large),
            todaySection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            todaySection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todaySection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            todaySectionHeader.topAnchor.constraint(equalTo: todaySection.topAnchor),
            todaySectionHeader.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: DesignTokens.Spacing.medium),
            todaySectionHeader.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -DesignTokens.Spacing.medium),
            todaySectionHeader.heightAnchor.constraint(equalToConstant: 40),

            todayTitleLabel.leadingAnchor.constraint(equalTo: todaySectionHeader.leadingAnchor),
            todayTitleLabel.centerYAnchor.constraint(equalTo: todaySectionHeader.centerYAnchor),

            todaySeeAllButton.trailingAnchor.constraint(equalTo: todaySectionHeader.trailingAnchor),
            todaySeeAllButton.centerYAnchor.constraint(equalTo: todaySectionHeader.centerYAnchor),

            habitsCollectionView.topAnchor.constraint(equalTo: todaySectionHeader.bottomAnchor, constant: DesignTokens.Spacing.medium),
            habitsCollectionView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor),
            habitsCollectionView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor),
            habitsCollectionView.bottomAnchor.constraint(equalTo: todaySection.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: todaySectionHeader.bottomAnchor, constant: DesignTokens.Spacing.large),
            emptyStateView.leadingAnchor.constraint(equalTo: todaySection.leadingAnchor, constant: DesignTokens.Spacing.medium),
            emptyStateView.trailingAnchor.constraint(equalTo: todaySection.trailingAnchor, constant: -DesignTokens.Spacing.medium),
            emptyStateView.bottomAnchor.constraint(equalTo: todaySection.bottomAnchor)
        ])
    }

    private func setupFloatingButton() {
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        view.addSubview(addHabitButton)

        NSLayoutConstraint.activate([
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignTokens.Spacing.large),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DesignTokens.Spacing.large),
            addHabitButton.widthAnchor.constraint(equalToConstant: 60),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupCollectionView() {
        habitsCollectionView.delegate = self
        habitsCollectionView.dataSource = self
        habitsCollectionView.register(HabitCardCell.self, forCellWithReuseIdentifier: "HabitCardCell")
    }

    // MARK: - Actions

    @objc private func profileTapped() {
        print("Profile button tapped")
        // Navigate to profile screen or perform relevant action
    }

    @objc private func addHabitTapped() {
        print("Add Habit button tapped")
        // Navigate to Add Habit screen or present a habit creation modal
    }

    @objc private func seeAllTapped() {
        print("See All button tapped")
        // Show all habits for today or navigate to a detailed view
    }

    private func updateUI(forLoadingState isLoading: Bool) {
        if isLoading {
            emptyStateView.isHidden = true
            habitsCollectionView.isHidden = true
            // Show skeleton views or placeholders
        } else {
            if todayHabits.isEmpty {
                emptyStateView.isHidden = false
                habitsCollectionView.isHidden = true
            } else {
                emptyStateView.isHidden = true
                habitsCollectionView.isHidden = false
                habitsCollectionView.reloadData()
            }
        }
    }

    // MARK: - Data Loading & Updates

    private func loadHabits() {
        isLoading = true
        updateUI(forLoadingState: true)

        HabitService.shared.getHabits { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let habits):
                    self.allHabits = habits
                    self.todayHabits = habits.filter { $0.shouldCompleteToday() }
                    self.updateUI(forLoadingState: false)
                    self.updateProgressState()
                    self.updateCalendarCompletion()

                case .failure(let error):
                    print("Error loading habits: \(error.localizedDescription)")
                    self.showError(message: "Failed to load your habits")
                }
            }
        }
    }

    private func updateCalendarCompletion() {
        let completedDates = Set(allHabits.flatMap { $0.completedDates })
        miniCalendar.setCompletionDates(completedDates)
    }

    private func updateProgressState() {
        let completedHabits = todayHabits.filter { $0.isCompletedToday() }.count
        let progress = Float(completedHabits) / Float(max(todayHabits.count, 1))
        circularProgress.setProgress(progress, animated: true)

        progressDescriptionLabel.text = completedHabits == todayHabits.count
            ? "All habits completed 🎉"
            : "\(completedHabits) of \(todayHabits.count) completed"
    }

    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: selectedDate)
    }

    private func animateComponentsIn() {
        // Add animations for components appearing
    }

    private func showError(message: String) {
        print(message)
        // Show an alert or appropriate error message in the UI
    }
}

// MARK: - Collection View Delegate & DataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todayHabits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCardCell", for: indexPath) as! HabitCardCell
        let habit = todayHabits[indexPath.item]
        cell.configure(with: habit)
        return cell
    }
}

// MARK: - Mini Calendar Delegate

extension HomeViewController: MiniCalendarViewDelegate {
    func miniCalendar(_ calendar: MiniCalendarView, didSelectDate date: Date) {
        selectedDate = date
        loadHabits()
    }
}
