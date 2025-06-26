import UIKit
import FirebaseAuth
import FirebaseFirestore

// Define a custom struct for friend analytics habits
struct FriendAnalyticsHabit {
    let title: String
    let colorHex: String
    let icon: String
    let completedDates: [Date]
    let daysArray: [Int]
    let timeString: String?
    let friendId: String?
    
    // Computed properties from AnalyticsHabit
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completed = Set(completedDates.map { calendar.startOfDay(for: $0) })
        var streak = 0
        for i in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { break }
            if completed.contains(day) { streak += 1 }
            else if i == 0 { return 0 }
            else { break }
        }
        return streak
    }
    
    var scheduledDays: [Int]? { daysArray }
    
    var completionRate: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var total = 0
        var completed = 0
        let set = Set(completedDates.map { calendar.startOfDay(for: $0) })
        for i in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { break }
            total += 1
            if set.contains(day) { completed += 1 }
        }
        return total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var lastCheckin: Date? { completedDates.sorted().last }
    
    // Conversion from QueryDocumentSnapshot
    static func fromFirestore(_ doc: QueryDocumentSnapshot) -> FriendAnalyticsHabit? {
        let data = doc.data()
        guard let title = data["title"] as? String else { return nil }
        guard let doneDatesRaw = data["doneDates"] as? [String: Any] else { return nil }
        
        var doneDates: [String: Bool] = [:]
        for (key, value) in doneDatesRaw {
            if let b = value as? Bool { doneDates[key] = b }
            else if let n = value as? NSNumber { doneDates[key] = n.boolValue }
            else if let i = value as? Int { doneDates[key] = i != 0 }
            else { doneDates[key] = false }
        }
        
        let colorHex = (data["colorHex"] as? String) ?? "#FF3B30"
        let icon = (data["icon"] as? String) ?? "circle"
        let friendId = data["friend"] as? String
        
        let completedDates: [Date] = doneDates.filter { $0.value }.compactMap {
            let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            return df.date(from: $0.key)
        }
        
        var daysArray: [Int] = []
        if let daysRaw = data["days"] as? [Any] {
            daysArray = daysRaw.compactMap { n in
                if let i = n as? Int { return i }
                if let n = n as? NSNumber { return n.intValue }
                return nil
            }
        }
        
        var timeString: String? = nil
        if let t = data["timeString"] as? String {
            timeString = t
        } else if let ts = data["schedule"] as? Timestamp {
            let date = ts.dateValue()
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            timeString = formatter.string(from: date)
        }
        
        return FriendAnalyticsHabit(
            title: title,
            colorHex: colorHex,
            icon: icon,
            completedDates: completedDates,
            daysArray: daysArray,
            timeString: timeString,
            friendId: friendId
        )
    }
    
    // Convert to AnalyticsHabit for use with HabitAnalyticsDetailViewController
    func toAnalyticsHabit() -> AnalyticsHabit {
        return AnalyticsHabit(
            title: title,
            colorHex: colorHex,
            icon: icon,
            completedDates: completedDates,
            daysArray: daysArray,
            timeString: timeString
        )
    }
}

class FriendAnalyticsViewController: UIViewController {
    // MARK: - Properties
    private let friend: UserProfile
    private let db = Firestore.firestore()
    private var sharedHabits: [FriendAnalyticsHabit] = []
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarView = UIView()
    private let avatarInitialLabel = UILabel()
    private let nameLabel = UILabel()
    
    // Stats views
    private let statsContainer = UIView()
    private let habitsCountView = StatItemView(title: "Shared Habits", iconName: "figure.2.and.child.holdinghands", iconColor: .systemBlue)
    private let completionView = StatItemView(title: "Avg Completion", iconName: "chart.pie.fill", iconColor: .systemPurple)
    private let messagesView = StatItemView(title: "Messages", iconName: "bubble.left.and.bubble.right.fill", iconColor: .systemGreen)
    
    // MARK: - Initializers
    init(friend: UserProfile) {
        self.friend = friend
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSharedHabits()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Base setup
        view.backgroundColor = .systemBackground
        
        // Setup scroll view for content
        setupScrollView()
        
        // Header setup with back button
        setupBackButton()
        
        // User profile section
        setupUserProfile()
        
        // Stats container
        setupStatsContainer()
        
        // Habits section
        setupHabitsSection()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
    
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .systemBlue
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        backButton.setTitle("Back", for: .normal)
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupUserProfile() {
        // Avatar setup - square with rounded corners like in the screenshot
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor.systemGray5
        avatarView.layer.cornerRadius = 45
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 1.5
        avatarView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        // Avatar initial label
        avatarInitialLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarInitialLabel.text = friend.displayName.first?.uppercased() ?? "?"
        avatarInitialLabel.textColor = .systemBlue
        avatarInitialLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        avatarInitialLabel.textAlignment = .center
        
        avatarView.addSubview(avatarInitialLabel)
        contentView.addSubview(avatarView)
        
        // Name label setup
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = friend.displayName
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 70),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 120),
            avatarView.heightAnchor.constraint(equalToConstant: 120),
            
            avatarInitialLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarInitialLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupStatsContainer() {
        // Container with rounded corners and subtle shadow
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.backgroundColor = .secondarySystemBackground
        statsContainer.layer.cornerRadius = 24
        
        // Add subtle shadow
        statsContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        statsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsContainer.layer.shadowRadius = 8
        statsContainer.layer.shadowOpacity = 1
        
        contentView.addSubview(statsContainer)
        
        // Stats row layout
        let stackView = UIStackView(arrangedSubviews: [habitsCountView, completionView, messagesView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .top
        
        statsContainer.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            statsContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            statsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsContainer.heightAnchor.constraint(equalToConstant: 120),
            
            stackView.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupHabitsSection() {
        // This will be populated dynamically when data is fetched
        // No tableView - we'll add habit cards directly to the content view
    }
    
    private func setupHabitCards() {
        // Clear any existing habit cards
        contentView.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Create a new habit card for each habit
        var lastAnchor = statsContainer.bottomAnchor
        let topPadding: CGFloat = 16
        
        for (index, habit) in sharedHabits.enumerated() {
            let card = createHabitCard(for: habit)
            card.tag = 999 // Tag for easy removal
            contentView.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: lastAnchor, constant: topPadding),
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                card.heightAnchor.constraint(equalToConstant: 130) // Higher card for better visibility
            ])
            
            lastAnchor = card.bottomAnchor
            
            // Add tap gesture to navigate to details
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(habitCardTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            card.isUserInteractionEnabled = true
            card.accessibilityIdentifier = "\(index)" // Store the index for access in the tap handler
        }
        
        // Add bottom spacing constraint
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: lastAnchor, constant: 100) // Add bottom space
        ])
        
        // If no habits, show empty state
        if sharedHabits.isEmpty {
            showEmptyState()
        }
    }
    
    private func createHabitCard(for habit: FriendAnalyticsHabit) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        // Get color from Firebase data
        let backgroundColor = UIColor(named: habit.colorHex)?.withAlphaComponent(0.2) ?? UIColor.systemRed.withAlphaComponent(0.2)
        cardView.backgroundColor = backgroundColor
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = habit.title
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold) // Larger font
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        cardView.addSubview(titleLabel)
        
        // Time label
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = habit.timeString ?? ""
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium)
        timeLabel.textColor = .black
        timeLabel.textAlignment = .right
        cardView.addSubview(timeLabel)
        
        // Chevron
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .black.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        cardView.addSubview(chevronImageView)
        
        // Days stack
        let daysStackView = UIStackView()
        daysStackView.translatesAutoresizingMaskIntoConstraints = false
        daysStackView.axis = .horizontal
        daysStackView.spacing = 6 // More spacing between day circles
        daysStackView.distribution = .fillEqually
        cardView.addSubview(daysStackView)
        
        // Configure day circles
        let dayInitials = ["S", "M", "T", "W", "T", "F", "S"]
        let habitColor = UIColor(named: habit.colorHex) ?? .systemRed
        
        for i in 0..<7 {
            let dayView = UIView()
            dayView.translatesAutoresizingMaskIntoConstraints = false
            dayView.heightAnchor.constraint(equalToConstant: 38).isActive = true // Larger circles
            dayView.widthAnchor.constraint(equalToConstant: 38).isActive = true
            dayView.layer.cornerRadius = 19 // Half of width/height
            
            // All active circles with habit color
            dayView.backgroundColor = habitColor
            
            // Day label
            let label = UILabel()
            label.text = dayInitials[i]
            label.font = UIFont.systemFont(ofSize: 16, weight: .bold) // Larger text
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            dayView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: dayView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: dayView.centerYAnchor)
            ])
            
            daysStackView.addArrangedSubview(dayView)
        }
        
        // Layout constraints - much more padding and spacing
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28), // More top padding
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -10),
            
            timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10),
            
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
            
            daysStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20), // More space after title
            daysStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            daysStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28) // More bottom padding
        ])
        
        return cardView
    }
    
    @objc private func habitCardTapped(_ sender: UITapGestureRecognizer) {
        guard let card = sender.view,
              let indexString = card.accessibilityIdentifier,
              let index = Int(indexString),
              index < sharedHabits.count else { return }
        
        let habit = sharedHabits[index]
        showHabitDetails(habit)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Data Fetching
    private func fetchSharedHabits() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // 1. Fetch current user's habits
        db.collection("users").document(currentUserId).collection("habits")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self, let docs = snapshot?.documents else { return }
                
                // Convert to habit objects and filter for shared habits with this friend
                let habitsWithFriend = docs.compactMap { FriendAnalyticsHabit.fromFirestore($0) }
                    .filter { $0.friendId == self.friend.uid }
                
                // Update UI with shared habits
                self.sharedHabits = habitsWithFriend
                self.updateStats()
                
                DispatchQueue.main.async {
                    // Create habit cards
                    self.setupHabitCards()
                    
                    // Show empty state if needed
                    if habitsWithFriend.isEmpty {
                        self.showEmptyState()
                    } else {
                        self.hideEmptyState()
                    }
                }
            }
    }
    
    private func updateStats() {
        // Update habits count stat
        habitsCountView.setValue("\(sharedHabits.count)")
        
        // Calculate and update completion rate
        var avgCompletion = 0
        if !sharedHabits.isEmpty {
            let totalCompletionRate = sharedHabits.reduce(0.0) { $0 + $1.completionRate }
            avgCompletion = Int(totalCompletionRate / Double(sharedHabits.count) * 100.0)
        }
        completionView.setValue("\(avgCompletion)%")
        
        // Update message count
        fetchMessageCount { [weak self] count in
            self?.messagesView.setValue("\(count)")
        }
    }
    
    private func fetchMessageCount(completion: @escaping (Int) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(0)
            return
        }
        
        // Create chat ID from user IDs (in sorted order)
        let chatId = [currentUserId, friend.uid].sorted().joined(separator: "_")
        
        // Get message count
        db.collection("chats").document(chatId).collection("messages")
            .getDocuments { snapshot, error in
                let count = snapshot?.documents.count ?? 0
                completion(count)
            }
    }
    
    // MARK: - Empty State
    private func showEmptyState() {
        hideEmptyState() // Clear any existing empty state view
        
        let emptyView = UIView()
        emptyView.tag = 100
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        // Message label
        let label = UILabel()
        label.text = "No shared habits with this friend yet"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(label)
        contentView.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 80),
            emptyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emptyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emptyView.heightAnchor.constraint(equalToConstant: 120),
            contentView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: 100),
            
            label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20)
        ])
    }
    
    private func hideEmptyState() {
        if let emptyView = contentView.viewWithTag(100) {
            emptyView.removeFromSuperview()
        }
    }
    
    // MARK: - Navigation
    private func showHabitDetails(_ habit: FriendAnalyticsHabit) {
        // Convert to regular AnalyticsHabit for use with detail view controller
        let analyticsHabit = habit.toAnalyticsHabit()
        let detailsVC = HabitAnalyticsDetailViewController(analyticsHabit: analyticsHabit)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - Custom UI Components
class StatItemView: UIView {
    private let iconView = UIImageView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    init(title: String, iconName: String, iconColor: UIColor) {
        super.init(frame: .zero)
        
        // Setup icon
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup value label
        valueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.text = "0"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup title label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack layout
        let stackView = UIStackView(arrangedSubviews: [iconView, valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}

// MARK: - Helper Extensions

