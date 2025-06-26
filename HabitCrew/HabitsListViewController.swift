import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

enum HabitListTab: Int, CaseIterable {
    case all, today, unchecked, done

    var title: String {
        switch self {
        case .all: return "All Habits"
        case .today: return "Today"
        case .unchecked: return "Unchecked"
        case .done: return "Done"
        }
    }
    var icon: String {
        switch self {
        case .all: return "tray.full"
        case .today: return "calendar"
        case .unchecked: return "circle"
        case .done: return "checkmark.circle.fill"
        }
    }
    var color: UIColor {
        switch self {
        case .all: return UIColor.systemBlue
        case .today: return UIColor.systemGray
        case .unchecked: return UIColor.systemOrange
        case .done: return UIColor.systemGreen
        }
    }
}

class HabitsListViewController: UIViewController {

    private var habits: [Habit] = []
    private var filteredHabits: [Habit] = []
    private var selectedTab: HabitListTab = .all {
        didSet { filterHabitsAndReload(); categoryTabBar.setNeedsDisplay() }
    }
    private let db = Firestore.firestore()
    private var habitsListener: ListenerRegistration?

    private let gradientLayer = CAGradientLayer()
    private let speechSynthesizer = AVSpeechSynthesizer()

    // Motivation
    private var userMotivation: String? {
        didSet { updateMotivationLabel() }
    }

    // Top Bar
    private let topBar = UIView()
    private let addHabitButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        let plus = UIImage(systemName: "plus.circle.fill")
        button.setImage(plus, for: .normal)
        button.setTitle(" Add Habit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.07)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        return button
    }()
    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()

    // Motivation Card
    private let motivationCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.11)
        v.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        v.layer.shadowOpacity = 1.0
        v.layer.shadowRadius = 8
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        return v
    }()
    private let motivationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 19)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 3
        label.text = "Stay motivated! 🚀"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let writeMotivationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Write Motivation", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.systemBackground
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()
    private let readMotivationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read Motivation", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.systemBackground
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()
    private let motivationButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // CATEGORY BAR - like screenshot: all tabs visible, compact, icon above, underline, no scroll
    private let categoryTabBar = CategoryTabBar()

    // MAIN CARD & TABLE
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 30
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        v.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.93)
        v.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.06).cgColor
        v.layer.shadowOpacity = 1.0
        v.layer.shadowRadius = 18
        v.layer.shadowOffset = CGSize(width: 0, height: 5)
        return v
    }()
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.contentInset = UIEdgeInsets.zero
        table.rowHeight = 116
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupTopBar()
        setupMotivation()
        setupTabBar()
        setupMainCardAndTable()
        fetchUserMotivation()
        listenForHabits()
        populateProfile()
    }

    deinit { habitsListener?.remove() }

    private func setupGradientBackground() {
        // Subtle blue-gradient background, no blobs
        gradientLayer.colors = [
            UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.97, green: 0.94, blue: 1.0, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.10, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupTopBar() {
        view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            topBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        topBar.addSubview(addHabitButton)
        topBar.addSubview(notificationButton)
        topBar.addSubview(profileButton)
        NSLayoutConstraint.activate([
            addHabitButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 10),
            addHabitButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            addHabitButton.heightAnchor.constraint(equalToConstant: 34),
            notificationButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -4),
            notificationButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 32),
            notificationButton.heightAnchor.constraint(equalToConstant: 32),
            profileButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -10),
            profileButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 32),
            profileButton.heightAnchor.constraint(equalToConstant: 32),
        ])
        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
    }

    private func setupMotivation() {
        view.addSubview(motivationCard)
        motivationCard.addSubview(motivationLabel)
        motivationCard.addSubview(motivationButtonStack)
        motivationButtonStack.addArrangedSubview(writeMotivationButton)
        motivationButtonStack.addArrangedSubview(readMotivationButton)
        NSLayoutConstraint.activate([
            motivationCard.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 4),
            motivationCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            motivationCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        NSLayoutConstraint.activate([
            motivationLabel.topAnchor.constraint(equalTo: motivationCard.topAnchor, constant: 12),
            motivationLabel.leadingAnchor.constraint(equalTo: motivationCard.leadingAnchor, constant: 12),
            motivationLabel.trailingAnchor.constraint(equalTo: motivationCard.trailingAnchor, constant: -12),
        ])
        NSLayoutConstraint.activate([
            motivationButtonStack.topAnchor.constraint(equalTo: motivationLabel.bottomAnchor, constant: 7),
            motivationButtonStack.leadingAnchor.constraint(equalTo: motivationCard.leadingAnchor, constant: 12),
            motivationButtonStack.trailingAnchor.constraint(equalTo: motivationCard.trailingAnchor, constant: -12),
            motivationButtonStack.bottomAnchor.constraint(equalTo: motivationCard.bottomAnchor, constant: -12),
            motivationButtonStack.heightAnchor.constraint(equalToConstant: 36)
        ])
        writeMotivationButton.addTarget(self, action: #selector(writeMotivationTapped), for: .touchUpInside)
        readMotivationButton.addTarget(self, action: #selector(readMotivationTapped), for: .touchUpInside)
    }

    private func setupTabBar() {
        view.addSubview(categoryTabBar)
        categoryTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTabBar.topAnchor.constraint(equalTo: motivationCard.bottomAnchor, constant: 8),
            categoryTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryTabBar.heightAnchor.constraint(equalToConstant: 66)
        ])
        categoryTabBar.configure(tabs: HabitListTab.allCases, selected: selectedTab.rawValue)
        categoryTabBar.onTabSelected = { [weak self] idx in
            guard let self = self else { return }
            self.selectedTab = HabitListTab(rawValue: idx) ?? .all
        }
    }

    private func setupMainCardAndTable() {
        view.addSubview(cardView)
        cardView.addSubview(blurView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: categoryTabBar.bottomAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        cardView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
        tableView.contentInset = .zero
        tableView.rowHeight = 116
        tableView.register(HabitCardCell.self, forCellReuseIdentifier: "habitcard")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func populateProfile() {
        if let currentUser = Auth.auth().currentUser, let url = currentUser.photoURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.profileButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }.resume()
        }
    }

    // MARK: - MOTIVATION CRUD

    private func fetchUserMotivation() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let doc = snapshot, let data = doc.data(), let motivation = data["motivation"] as? String, !motivation.isEmpty {
                self.userMotivation = motivation
            } else {
                self.userMotivation = nil
            }
        }
    }
    private func updateMotivationLabel() {
        if let motivation = self.userMotivation, !motivation.isEmpty {
            self.motivationLabel.text = "\(motivation)"
        } else {
            self.motivationLabel.text = "Stay motivated! 🚀"
        }
    }
    @objc private func writeMotivationTapped() {
        let alert = UIAlertController(title: "Write Motivation", message: "Enter something to motivate yourself!", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Your motivation"
            textField.text = self.userMotivation
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self, let uid = Auth.auth().currentUser?.uid else { return }
            let text = alert.textFields?.first?.text ?? ""
            self.db.collection("users").document(uid).setData(["motivation": text], merge: true) { error in
                if error == nil {
                    self.userMotivation = text
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    @objc private func readMotivationTapped() {
        let text = (self.userMotivation?.isEmpty ?? true) ? "No motivation set yet!" : self.userMotivation!
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
        let alert = UIAlertController(title: "Your Motivation", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @objc private func addHabitTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let addVC = AddHabitViewController()
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }

    // MARK: - FIRESTORE SYNC

    private func listenForHabits() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        habitsListener?.remove()
        habitsListener = db.collection("users").document(uid).collection("habits")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error loading habits: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.habits = documents.compactMap { doc in Habit(from: doc.data()) }
                self.filterHabitsAndReload()
            }
    }
    private func saveHabitToFirestore(_ habit: Habit) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid).collection("habits").document(habit.id)
        ref.setData(habit.dictionary) { error in
            if let error = error {
                print("Failed to save habit: \(error)")
            }
        }
    }
    private func filterHabitsAndReload() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = (calendar.component(.weekday, from: today) + 6) % 7
        switch selectedTab {
        case .all:
            filteredHabits = habits
        case .today:
            filteredHabits = habits.filter { $0.days.contains(weekday) }
        case .unchecked:
            filteredHabits = habits.filter { $0.days.contains(weekday) && !$0.isDoneToday() }
        case .done:
            filteredHabits = habits.filter { $0.days.contains(weekday) && $0.isDoneToday() }
        }
        tableView.reloadData()
    }
    func markHabitToggleDoneForToday(_ habit: Habit) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var updatedHabit = habit
        let today = Habit.dateString()
        let currentlyDone = habit.doneDates[today] == true
        updatedHabit.doneDates[today] = !currentlyDone
        db.collection("users").document(uid).collection("habits").document(habit.id)
            .setData(updatedHabit.dictionary, merge: true)
    }
    func showHabitDetails(_ habit: Habit) {
        let detailsVC = HabitDetailViewController(habit: habit)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    private func editHabit(_ habit: Habit) {
        let addVC = AddHabitViewController(habitToEdit: habit)
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }
    private func deleteHabit(_ habit: Habit) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("habits").document(habit.id).delete()
    }
}

// MARK: - CategoryTabBar
class CategoryTabBar: UIView {
    private var tabViews: [UIView] = []
    private var underline: UIView?
    private var tabs: [HabitListTab] = []
    var onTabSelected: ((Int) -> Void)?

    private let iconSize: CGFloat = 24
    private let tabHeight: CGFloat = 60

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(tabs: [HabitListTab], selected: Int) {
        self.tabs = tabs
        tabViews.forEach { $0.removeFromSuperview() }
        tabViews = []
        let count = tabs.count
        let tabWidth = UIScreen.main.bounds.width / CGFloat(count)
        for (i, tab) in tabs.enumerated() {
            let v = UIButton(type: .custom)
            v.frame = CGRect(x: CGFloat(i) * tabWidth, y: 0, width: tabWidth, height: tabHeight)
            v.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            v.tag = i

            let iconView = UIImageView(image: UIImage(systemName: tab.icon))
            iconView.tintColor = (i == selected) ? tab.color : .systemGray3
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = tab.title
            label.font = i == selected ? .boldSystemFont(ofSize: 13.5) : .systemFont(ofSize: 13.5, weight: .medium)
            label.textColor = (i == selected) ? tab.color : .systemGray3
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            v.addSubview(iconView)
            v.addSubview(label)
            NSLayoutConstraint.activate([
                iconView.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                iconView.topAnchor.constraint(equalTo: v.topAnchor, constant: 7),
                iconView.widthAnchor.constraint(equalToConstant: iconSize),
                iconView.heightAnchor.constraint(equalToConstant: iconSize),
                label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 3),
                label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                label.widthAnchor.constraint(equalToConstant: tabWidth - 12)
            ])
            tabViews.append(v)
            addSubview(v)
        }
        underline?.removeFromSuperview()
        let underline = UIView()
        underline.backgroundColor = tabs[selected].color
        underline.layer.cornerRadius = 2
        let uw = tabWidth * 0.56
        underline.frame = CGRect(x: CGFloat(selected) * tabWidth + (tabWidth - uw)/2, y: tabHeight-4, width: uw, height: 3)
        addSubview(underline)
        self.underline = underline
    }

    @objc private func tabTapped(_ sender: UIButton) {
        setSelected(idx: sender.tag)
        onTabSelected?(sender.tag)
    }

    func setSelected(idx: Int) {
        guard !tabs.isEmpty else { return }
        let count = tabs.count
        let tabWidth = UIScreen.main.bounds.width / CGFloat(count)
        for (i, v) in tabViews.enumerated() {
            let tab = tabs[i]
            let iconView = v.subviews.compactMap{ $0 as? UIImageView }.first
            let label = v.subviews.compactMap{ $0 as? UILabel }.first
            iconView?.tintColor = (i == idx) ? tab.color : .systemGray3
            label?.font = i == idx ? .boldSystemFont(ofSize: 13.5) : .systemFont(ofSize: 13.5, weight: .medium)
            label?.textColor = (i == idx) ? tab.color : .systemGray3
        }
        underline?.backgroundColor = tabs[idx].color
        let uw = tabWidth * 0.56
        UIView.animate(withDuration: 0.15) {
            self.underline?.frame = CGRect(x: CGFloat(idx) * tabWidth + (tabWidth - uw)/2, y: self.tabHeight-4, width: uw, height: 3)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !tabs.isEmpty {
            configure(tabs: tabs, selected: tabViews.firstIndex(where: { ($0.subviews.compactMap{ $0 as? UILabel }.first?.font == UIFont.boldSystemFont(ofSize: 13.5)) }) ?? 0)
        }
    }
}

// MARK: - TableView Delegate/DataSource

extension HabitsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHabits.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = filteredHabits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "habitcard", for: indexPath) as! HabitCardCell
        let calendar = Calendar.current
        let today = Date()
        let weekday = (calendar.component(.weekday, from: today) + 6) % 7
        let isScheduledToday = habit.days.contains(weekday)
        cell.configureNoIcon(with: habit, isScheduledToday: isScheduledToday)
        cell.onCardTapped = { [weak self] in
            guard let self = self else { return }
            if isScheduledToday {
                self.markHabitToggleDoneForToday(habit)
            }
        }
        cell.onDetailsTapped = { [weak self] in
            self?.showHabitDetails(habit)
        }
        return cell
    }
    // Swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete card style
        let habit = filteredHabits[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            self?.deleteHabit(habit)
            completion(true)
        }
        let icon = UIImage(systemName: "trash.fill")
        delete.image = icon
        delete.backgroundColor = UIColor.systemRed.withAlphaComponent(0.13)
        delete.title = nil
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Edit card style
        let habit = filteredHabits[indexPath.row]
        let edit = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            self?.editHabit(habit)
            completion(true)
        }
        let icon = UIImage(systemName: "pencil")
        edit.image = icon
        edit.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
        edit.title = nil
        return UISwipeActionsConfiguration(actions: [edit])
    }
}

// MARK: - AddHabitViewControllerDelegate

extension HabitsListViewController: AddHabitViewControllerDelegate {
    func didAddHabit(_ habit: Habit) {
        saveHabitToFirestore(habit)
    }
    func didEditHabit(_ habit: Habit) {
        saveHabitToFirestore(habit)
    }
}

// MARK: - Apple-style Habit Card Cell (without icon)

class HabitCardCell: UITableViewCell {
    private let card = UIView()
    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let daysStack = UIStackView()
    private let timeLabel = UILabel()
    private let detailsArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    var onCardTapped: (() -> Void)?
    var onDetailsTapped: (() -> Void)?
    private var isScheduledToday: Bool = true

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configureNoIcon(with habit: Habit, isScheduledToday: Bool = true) {
        self.isScheduledToday = isScheduledToday
        let color = UIColor(hex: habit.colorHex) ?? .systemBlue
        let isDoneToday = habit.isDoneToday()
        card.layer.borderWidth = 0
        card.layer.borderColor = UIColor.clear.cgColor
        card.backgroundColor = isDoneToday ? color.withAlphaComponent(0.26) : color.withAlphaComponent(0.13)

        titleLabel.text = habit.title
        noteLabel.text = habit.note

        let days = habit.days
        let dayLetters = ["S","M","T","W","T","F","S"]

        daysStack.arrangedSubviews.forEach { daysStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        for i in 0..<7 {
            let day = dayLetters[i]
            let isActive = days.contains(i)
            let lbl = UILabel()
            lbl.text = day
            lbl.font = UIFont.systemFont(ofSize: 13.5, weight: .semibold)
            lbl.textAlignment = .center
            lbl.textColor = .black // Black text for days
            lbl.backgroundColor = isActive ? color : UIColor.systemGray5
            lbl.layer.cornerRadius = 12
            lbl.layer.masksToBounds = true
            lbl.widthAnchor.constraint(equalToConstant: 24).isActive = true
            lbl.heightAnchor.constraint(equalToConstant: 24).isActive = true
            daysStack.addArrangedSubview(lbl)
        }
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeLabel.text = timeFormatter.string(from: habit.schedule)
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15.5, weight: .medium)
        timeLabel.textColor = .black // Time in black

        card.isUserInteractionEnabled = isScheduledToday
        card.alpha = isScheduledToday ? 1.0 : 0.5
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(detailsArrow)
        card.addSubview(daysStack)
        card.addSubview(timeLabel)
        card.addSubview(noteLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label

        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        noteLabel.textColor = .secondaryLabel
        noteLabel.numberOfLines = 1

        daysStack.axis = .horizontal
        daysStack.spacing = 5
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        daysStack.alignment = .center
        daysStack.distribution = .fill

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .right

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            detailsArrow.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            detailsArrow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            detailsArrow.widthAnchor.constraint(equalToConstant: 20),
            detailsArrow.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: detailsArrow.leadingAnchor, constant: -10),

            daysStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            daysStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            daysStack.heightAnchor.constraint(equalToConstant: 24),

            timeLabel.centerYAnchor.constraint(equalTo: daysStack.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true

        let arrowTap = UITapGestureRecognizer(target: self, action: #selector(detailsTapped))
        detailsArrow.isUserInteractionEnabled = true
        detailsArrow.addGestureRecognizer(arrowTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cardLongPressed))
        card.addGestureRecognizer(longPress)
    }

    @objc private func cardTapped() {
        if isScheduledToday {
            UIView.animate(withDuration: 0.1, animations: {
                self.card.backgroundColor = self.card.backgroundColor?.withAlphaComponent(0.40)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.card.backgroundColor = self.card.backgroundColor?.withAlphaComponent(0.26)
                }
            })
            onCardTapped?()
        }
    }
    @objc private func cardLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            onDetailsTapped?()
        }
    }
    @objc private func detailsTapped() {
        onDetailsTapped?()
    }
}

// MARK: - UIColor hex string convenience
private extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
