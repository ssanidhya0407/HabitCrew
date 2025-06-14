import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

class HabitsListViewController: UIViewController {

    private var habits: [Habit] = []
    private let db = Firestore.firestore()
    private var habitsListener: ListenerRegistration?

    private let gradientLayer = CAGradientLayer()
    private let decorativeBlob1 = UIView()
    private let decorativeBlob2 = UIView()
    private let speechSynthesizer = AVSpeechSynthesizer()

    // Motivation
    private var userMotivation: String? {
        didSet { updateMotivationLabel() }
    }

    // Greeting and subtitle
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "Welcome 👋"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Here are your habits for today"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        table.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        table.rowHeight = 88
        return table
    }()

    private let addHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Habit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        setupUI()
        populateUserInfo()
        fetchUserMotivation()
        listenForHabits()
    }

    deinit {
        habitsListener?.remove()
    }

    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.97, green: 0.94, blue: 1.0, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.10, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupDecorativeBlobs() {
        decorativeBlob1.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        decorativeBlob1.layer.cornerRadius = 100
        decorativeBlob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob1)
        NSLayoutConstraint.activate([
            decorativeBlob1.widthAnchor.constraint(equalToConstant: 190),
            decorativeBlob1.heightAnchor.constraint(equalToConstant: 190),
            decorativeBlob1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -48),
            decorativeBlob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -48)
        ])
        decorativeBlob2.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.07)
        decorativeBlob2.layer.cornerRadius = 100
        decorativeBlob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob2)
        NSLayoutConstraint.activate([
            decorativeBlob2.widthAnchor.constraint(equalToConstant: 190),
            decorativeBlob2.heightAnchor.constraint(equalToConstant: 190),
            decorativeBlob2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 48),
            decorativeBlob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 48)
        ])
    }

    private func setupUI() {
        // Welcome and subtitle at the very top
        view.addSubview(greetingLabel)
        view.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            greetingLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -25),
            subtitleLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
        ])

        // Motivation Card
        view.addSubview(motivationCard)
        motivationCard.addSubview(motivationLabel)
        motivationCard.addSubview(motivationButtonStack)
        motivationButtonStack.addArrangedSubview(writeMotivationButton)
        motivationButtonStack.addArrangedSubview(readMotivationButton)
        NSLayoutConstraint.activate([
            motivationCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            motivationCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            motivationCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        NSLayoutConstraint.activate([
            motivationLabel.topAnchor.constraint(equalTo: motivationCard.topAnchor, constant: 16),
            motivationLabel.leadingAnchor.constraint(equalTo: motivationCard.leadingAnchor, constant: 16),
            motivationLabel.trailingAnchor.constraint(equalTo: motivationCard.trailingAnchor, constant: -16),
        ])
        NSLayoutConstraint.activate([
            motivationButtonStack.topAnchor.constraint(equalTo: motivationLabel.bottomAnchor, constant: 12),
            motivationButtonStack.leadingAnchor.constraint(equalTo: motivationCard.leadingAnchor, constant: 16),
            motivationButtonStack.trailingAnchor.constraint(equalTo: motivationCard.trailingAnchor, constant: -16),
            motivationButtonStack.bottomAnchor.constraint(equalTo: motivationCard.bottomAnchor, constant: -16),
            motivationButtonStack.heightAnchor.constraint(equalToConstant: 44)
        ])

        writeMotivationButton.addTarget(self, action: #selector(writeMotivationTapped), for: .touchUpInside)
        readMotivationButton.addTarget(self, action: #selector(readMotivationTapped), for: .touchUpInside)

        // Add Habit Button at bottom
        view.addSubview(addHabitButton)
        NSLayoutConstraint.activate([
            addHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            addHabitButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Card background & blur
        view.addSubview(cardView)
        cardView.addSubview(blurView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: motivationCard.bottomAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: addHabitButton.topAnchor, constant: -18)
        ])
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        // TableView inside cardView
        cardView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])

        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 88
        tableView.register(HabitCardCell.self, forCellReuseIdentifier: "habitcard")

        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func populateUserInfo() {
        if let user = Auth.auth().currentUser {
            let displayName = user.displayName ?? ""
            greetingLabel.text = displayName.isEmpty ? "Welcome 👋" : "Welcome, \(displayName) 👋"
        }
    }

    // MARK: - Motivation CRUD

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
            self.motivationLabel.text = "✨ Your Motivation: \(motivation)"
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

    // MARK: - Firebase Sync

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
                self.tableView.reloadData()
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

    // MARK: - Mark Habit Toggle Done/Undone
    func markHabitToggleDoneForToday(_ habit: Habit) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var updatedHabit = habit
        let today = Habit.dateString()
        let currentlyDone = habit.doneDates[today] == true
        updatedHabit.doneDates[today] = !currentlyDone
        db.collection("users").document(uid).collection("habits").document(habit.id)
            .setData(updatedHabit.dictionary, merge: true)
    }

    // MARK: - Show Details
    func showHabitDetails(_ habit: Habit) {
        let detailsVC = HabitDetailViewController(habit: habit)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - TableView Delegate/DataSource

extension HabitsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "habitcard", for: indexPath) as! HabitCardCell
        cell.configure(with: habit)
        cell.onCardTapped = { [weak self] in
            self?.markHabitToggleDoneForToday(habit)
        }
        cell.onDetailsTapped = { [weak self] in
            self?.showHabitDetails(habit)
        }
        return cell
    }
}

// MARK: - AddHabitViewControllerDelegate

extension HabitsListViewController: AddHabitViewControllerDelegate {
    func didAddHabit(_ habit: Habit) {
        saveHabitToFirestore(habit)
        // Listener will auto-refresh table
    }
}

// MARK: - Apple-style Habit Card Cell

class HabitCardCell: UITableViewCell {
    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let daysStack = UIStackView()
    private let timeLabel = UILabel()

    var onCardTapped: (() -> Void)?
    var onDetailsTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with habit: Habit) {
        let color = UIColor(hex: habit.colorHex) ?? .systemBlue
        card.backgroundColor = color.withAlphaComponent(habit.isDoneToday() ? 0.3 : 0.13)
        iconView.image = UIImage(systemName: habit.icon)?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = color
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
            lbl.textColor = isActive ? .white : .label
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
        timeLabel.textColor = color
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        card.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.12)
        contentView.addSubview(card)
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(noteLabel)
        card.addSubview(daysStack)
        card.addSubview(timeLabel)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true
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
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            noteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            noteLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            daysStack.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 8),
            daysStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            daysStack.heightAnchor.constraint(equalToConstant: 24),

            timeLabel.centerYAnchor.constraint(equalTo: daysStack.centerYAnchor),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: daysStack.trailingAnchor, constant: 14),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        // Tap gesture for marking done/undone
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true

        // Long press for details
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cardLongPressed))
        card.addGestureRecognizer(longPress)
    }

    @objc private func cardTapped() {
        onCardTapped?()
    }
    @objc private func cardLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            onDetailsTapped?()
        }
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
