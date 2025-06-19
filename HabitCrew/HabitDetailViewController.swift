import UIKit
import FirebaseAuth
import FirebaseFirestore

class HabitDetailViewController: UIViewController {

    private let habit: Habit
    private var buddyNameLabel: UILabel?

    // Decorative blobs
    private let decorativeBlob1 = UIView()
    private let decorativeBlob2 = UIView()
    private let gradientLayer = CAGradientLayer()

    // For animation and info sheet
    private var daysRow: UIStackView?
    private var timeCard: UIView?
    private var statsStack: UIStackView?
    private var motiCard: UIView?
    private var friendCard: UIView?

    // MARK: - Init
    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        setupUI()
        animateStats()
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
        decorativeBlob1.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.09)
        decorativeBlob1.layer.cornerRadius = 120
        decorativeBlob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob1)
        NSLayoutConstraint.activate([
            decorativeBlob1.widthAnchor.constraint(equalToConstant: 220),
            decorativeBlob1.heightAnchor.constraint(equalToConstant: 220),
            decorativeBlob1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -50),
            decorativeBlob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -70)
        ])
        decorativeBlob2.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.08)
        decorativeBlob2.layer.cornerRadius = 120
        decorativeBlob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob2)
        NSLayoutConstraint.activate([
            decorativeBlob2.widthAnchor.constraint(equalToConstant: 220),
            decorativeBlob2.heightAnchor.constraint(equalToConstant: 220),
            decorativeBlob2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 60),
            decorativeBlob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 70)
        ])
    }

    private func setupUI() {
        // Heading
        let headingLabel = UILabel()
        headingLabel.text = "Habit Details"
        headingLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        headingLabel.textColor = .label
        headingLabel.textAlignment = .center
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headingLabel)
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Back button
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .systemBlue
        backButton.semanticContentAttribute = .forceLeftToRight
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: headingLabel.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            backButton.widthAnchor.constraint(equalToConstant: 70)
        ])

        // The main card (glassmorphic)
        let card = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        card.backgroundColor = UIColor.white.withAlphaComponent(0.38)
        card.layer.cornerRadius = 38
        card.clipsToBounds = true
        card.layer.masksToBounds = true
        card.layer.borderWidth = 0.4
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            card.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 18),
            card.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14)
        ])

        // Main vertical stack
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 36),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.contentView.bottomAnchor, constant: -54)
        ])

        // -- Icon in colored bubble --
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.layer.cornerRadius = 44
        iconBg.backgroundColor = (UIColor(hex: habit.colorHex) ?? .systemYellow).withAlphaComponent(0.18)
        let iconView = UIImageView(image: UIImage(systemName: habit.icon))
        iconView.tintColor = UIColor(hex: habit.colorHex) ?? .systemYellow
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 88),
            iconBg.heightAnchor.constraint(equalToConstant: 88),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor)
        ])
        stack.addArrangedSubview(iconBg)

        // -- Title --
        let titleLabel = UILabel()
        titleLabel.text = habit.title
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        stack.addArrangedSubview(titleLabel)

        // -- Friend card (if any) --
        if !habit.friend.isEmpty {
            let label = UILabel()
            label.text = "Loading..."
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .systemGray
            self.buddyNameLabel = label
            let friendCard = smallInfoCard(icon: "person.crop.circle.fill", color: .systemGray, customLabel: label)
            self.friendCard = friendCard
            stack.addArrangedSubview(friendCard)
            fetchFriendNameAndUpdateUI()
        }

        // -- Days row (like list) & animated --
        let daysRow = UIStackView()
        daysRow.axis = .horizontal
        daysRow.spacing = 7
        daysRow.alignment = .center
        let dayLetters = ["S","M","T","W","T","F","S"]
        for i in 0..<7 {
            let lbl = UILabel()
            lbl.text = dayLetters[i]
            lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            lbl.textAlignment = .center
            let isActive = habit.days.contains(i)
            lbl.textColor = isActive ? .white : UIColor(white: 0.7, alpha: 1)
            lbl.backgroundColor = isActive ? (UIColor(hex: habit.colorHex) ?? .systemYellow) : UIColor.systemGray5
            lbl.layer.cornerRadius = 17
            lbl.layer.masksToBounds = true
            lbl.widthAnchor.constraint(equalToConstant: 34).isActive = true
            lbl.heightAnchor.constraint(equalToConstant: 34).isActive = true
            lbl.alpha = 0
            daysRow.addArrangedSubview(lbl)
        }
        self.daysRow = daysRow
        stack.addArrangedSubview(daysRow)

        // -- Time card (glassmorphic, full width) --
        let timeCard = statCard(
            icon: "clock",
            color: UIColor(hex: habit.colorHex) ?? .systemYellow,
            text: DateFormatter.localizedString(from: habit.schedule, dateStyle: .none, timeStyle: .short),
            fontSize: 24,
            glass: true,
            textColor: .black // Always readable
        )
        timeCard.alpha = 0
        self.timeCard = timeCard
        stack.addArrangedSubview(timeCard)

        // -- Progress/Stats: stacked vertically, wide cards with info button --
        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.alignment = .fill
        statsStack.distribution = .equalSpacing
        statsStack.spacing = 14
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        let (streak, _) = habit.currentStreakAndDates()
        let (bestStreak, _) = habit.bestStreakAndDates()
        let totalCompletions = habit.doneDates.values.filter { $0 }.count

        let streakCard = statCard(icon: "flame", color: .systemOrange, text: "\(streak) day streak", glass: true, textColor: .black, infoType: .streak)
        let bestCard = statCard(icon: "bolt", color: .systemYellow, text: "\(bestStreak) best", glass: true, textColor: .black, infoType: .best)
        let doneCard = statCard(icon: "checkmark.circle", color: .systemGreen, text: "\(totalCompletions) done", glass: true, textColor: .black, infoType: .done)

        statsStack.addArrangedSubview(streakCard)
        statsStack.addArrangedSubview(bestCard)
        statsStack.addArrangedSubview(doneCard)
        statsStack.alpha = 0
        self.statsStack = statsStack
        stack.addArrangedSubview(statsStack)

        // -- Motivation (if any) --
        if let motivation = habit.motivation, !motivation.isEmpty {
            let motiCard = statCard(icon: "sparkles", color: .systemBlue, text: motivation, filled: true, glass: true, textColor: .black)
            motiCard.alpha = 0
            self.motiCard = motiCard
            stack.addArrangedSubview(motiCard)
        }

        // -- Created row at the bottom --
        let createdLabel = UILabel()
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        createdLabel.text = "Created \(df.string(from: habit.createdAt))"
        createdLabel.font = .systemFont(ofSize: 16, weight: .regular)
        createdLabel.textColor = .tertiaryLabel
        createdLabel.textAlignment = .center
        createdLabel.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(createdLabel)
        NSLayoutConstraint.activate([
            createdLabel.centerXAnchor.constraint(equalTo: card.contentView.centerXAnchor),
            createdLabel.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -18)
        ])
    }

    private func fetchFriendNameAndUpdateUI() {
        guard let currentUserId = Auth.auth().currentUser?.uid, !habit.friend.isEmpty else {
            print("[DEBUG] No user or empty habit.friend")
            buddyNameLabel?.text = "Unknown"
            return
        }
        let db = Firestore.firestore()
        print("[DEBUG] Looking up friend displayName for friend id: \(habit.friend) under user: \(currentUserId)")
        let friendRef = db.collection("users").document(currentUserId).collection("friends").document(habit.friend)
        friendRef.getDocument { [weak self] snapshot, error in
            print("[DEBUG] Firestore responded for friend id: \(self?.habit.friend ?? "nil"), error: \(String(describing: error))")
            var name = "Unknown"
            if let data = snapshot?.data() {
                print("[DEBUG] Friend data found: \(data)")
                if let displayName = data["displayName"] as? String, !displayName.isEmpty {
                    name = displayName
                } else if let nameField = data["name"] as? String, !nameField.isEmpty {
                    name = nameField
                } else if let email = data["email"] as? String, !email.isEmpty {
                    name = email
                }
            } else {
                print("[DEBUG] No friend data found for id \(self?.habit.friend ?? "nil")")
            }
            DispatchQueue.main.async {
                print("[DEBUG] Setting buddyNameLabel.text = \(name)")
                self?.buddyNameLabel?.text = name
            }
        }
    }

    // Helper to build the card with a label reference
    private func smallInfoCard(icon: String, color: UIColor, customLabel: UILabel) -> UIView {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        v.backgroundColor = color.withAlphaComponent(0.13)
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let row = UIStackView(arrangedSubviews: [img, customLabel])
        row.axis = .horizontal
        row.spacing = 7
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        v.contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: v.contentView.leadingAnchor, constant: 13),
            row.trailingAnchor.constraint(equalTo: v.contentView.trailingAnchor, constant: -13),
            row.centerYAnchor.constraint(equalTo: v.contentView.centerYAnchor)
        ])
        v.alpha = 0
        UIView.animate(withDuration: 0.3) { v.alpha = 1 }
        return v
    }

    // Update the label in the friendCard UI
    private func updateBuddyNameUI() {
        if let friendCard = self.friendCard,
           let stack = friendCard.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let label = stack.arrangedSubviews.last as? UILabel
        {
            label.text = buddyNameLabel?.text
        }
    }

    // MARK: - Animated appearance
    private func animateStats() {
        guard let daysRow = daysRow else { return }
        for (i, lbl) in daysRow.arrangedSubviews.enumerated() {
            UIView.animate(withDuration: 0.3, delay: 0.08*Double(i), options: .curveEaseOut, animations: {
                lbl.alpha = 1
                lbl.transform = .identity
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.44, delay: 0.44, options: .curveEaseOut, animations: {
            self.timeCard?.alpha = 1
            self.statsStack?.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.35, delay: 0.88, options: .curveEaseOut, animations: {
            self.motiCard?.alpha = 1
            self.friendCard?.alpha = 1
        }, completion: nil)
    }

    // MARK: - Modern glassmorphic stat card (full width, readable) with optional info button
    enum StatInfoType { case streak, best, done, none }
    private func statCard(icon: String, color: UIColor, text: String, fontSize: CGFloat = 18, filled: Bool = false, glass: Bool = false, textColor: UIColor? = nil, infoType: StatInfoType = .none) -> UIView {
        let card: UIView
        if glass {
            let ve = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
            ve.backgroundColor = filled ? color.withAlphaComponent(0.22) : color.withAlphaComponent(0.17)
            ve.layer.cornerRadius = 18
            ve.clipsToBounds = true
            ve.layer.borderWidth = 0.5
            ve.layer.borderColor = color.withAlphaComponent(0.18).cgColor
            ve.translatesAutoresizingMaskIntoConstraints = false
            card = ve
            ve.heightAnchor.constraint(equalToConstant: 50).isActive = true
            ve.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 68).isActive = true
        } else {
            let v = UIView()
            v.backgroundColor = filled ? color.withAlphaComponent(0.17) : color.withAlphaComponent(0.12)
            v.layer.cornerRadius = 18
            v.translatesAutoresizingMaskIntoConstraints = false
            v.heightAnchor.constraint(equalToConstant: 50).isActive = true
            v.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 68).isActive = true
            card = v
        }

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: fontSize, weight: .semibold)
        lbl.textColor = textColor ?? (color.isLight ? .black : .white)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        lbl.lineBreakMode = .byTruncatingTail
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.distribution = .fill

        // Add info button if needed
        if infoType != .none {
            let infoBtn = UIButton(type: .system)
            infoBtn.setImage(UIImage(systemName: "info.circle"), for: .normal)
            infoBtn.tintColor = .gray
            infoBtn.translatesAutoresizingMaskIntoConstraints = false
            infoBtn.widthAnchor.constraint(equalToConstant: 24).isActive = true
            infoBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
            row.addArrangedSubview(infoBtn)
            infoBtn.addTarget(self, action: #selector(handleInfoButton(_:)), for: .touchUpInside)
            infoBtn.tag = infoType == .streak ? 1 : infoType == .best ? 2 : 3
        }

        row.translatesAutoresizingMaskIntoConstraints = false

        if let ve = card as? UIVisualEffectView {
            ve.contentView.addSubview(row)
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: ve.contentView.leadingAnchor, constant: 20),
                row.trailingAnchor.constraint(equalTo: ve.contentView.trailingAnchor, constant: -20),
                row.centerYAnchor.constraint(equalTo: ve.contentView.centerYAnchor)
            ])
        } else {
            card.addSubview(row)
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                row.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
        }
        // Make the card tappable for info sheet as well
        if infoType != .none {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
            card.tag = infoType == .streak ? 1 : infoType == .best ? 2 : 3
        }

        return card
    }

    // MARK: - Small info card (for friend name)
    private func smallInfoCard(icon: String, color: UIColor, text: String) -> UIView {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        v.backgroundColor = color.withAlphaComponent(0.13)
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 17, weight: .medium)
        lbl.textColor = color
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis = .horizontal
        row.spacing = 7
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        v.contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: v.contentView.leadingAnchor, constant: 13),
            row.trailingAnchor.constraint(equalTo: v.contentView.trailingAnchor, constant: -13),
            row.centerYAnchor.constraint(equalTo: v.contentView.centerYAnchor)
        ])
        v.alpha = 0
        return v
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Info Sheet logic
    @objc private func handleInfoButton(_ sender: UIButton) {
        showInfoSheet(for: sender.tag)
    }
    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        showInfoSheet(for: tag)
    }
    private func showInfoSheet(for tag: Int) {
        var title: String = ""
        var message: String = ""
        var dates: [String] = []
        var statType: InfoSheetViewController.StatType = .streak
        var accentColor: UIColor = .systemOrange

        switch tag {
        case 1:
            title = "Current Streak"
            let (count, streakDates) = habit.currentStreakAndDates()
            message = "Your current streak is \(count) day(s). These are consecutive days you have marked this habit as done."
            dates = streakDates
            statType = .streak
            accentColor = .systemRed
        case 2:
            title = "Best Streak"
            let (count, bestDates) = habit.bestStreakAndDates()
            message = "Your best streak is \(count) day(s). These are the dates for your best streak:"
            dates = bestDates
            statType = .best
            accentColor = .systemOrange // Prefer blue for best
        case 3:
            title = "Total Done"
            let doneDates = habit.doneDates.filter { $0.value }.keys.sorted()
            message = "You have completed this habit on \(doneDates.count) day(s). Here are the dates:"
            dates = doneDates
            statType = .done
            accentColor = .systemGreen
        default: return
        }

        let vc = InfoSheetViewController(title: title, message: message, dates: dates, statType: statType, accentColor: accentColor)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                let baseHeight: CGFloat = 160
                let dateRows = CGFloat(max(1, (dates.count+2)/3))
                return baseHeight + dateRows*45
            })]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
}

// MARK: - Info Sheet View Controller

class InfoSheetViewController: UIViewController {
    private var titleStr: String = ""
    private var msg: String = ""
    private var dateStrings: [String] = []
    private var statType: StatType = .streak
    private var accentColor: UIColor = .systemYellow

    enum StatType { case streak, best, done }

    init(title: String, message: String, dates: [String], statType: StatType = .streak, accentColor: UIColor = .systemYellow) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .pageSheet
        self.titleStr = title
        self.msg = message
        self.dateStrings = dates
        self.statType = statType
        self.accentColor = accentColor
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        // --- Translucent Glass Background ---
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.layer.cornerRadius = 28
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blur, at: 0)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            blur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        // --- Soft shadow for polish ---
        blur.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        blur.layer.shadowOpacity = 1
        blur.layer.shadowOffset = CGSize(width: 0, height: 3)
        blur.layer.shadowRadius = 28

        // --- Gradient/Colored Accent Bar ---
        let accent = UIView()
        accent.translatesAutoresizingMaskIntoConstraints = false
        accent.layer.cornerRadius = 4
        accent.clipsToBounds = true
        accent.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.colors = accentBarColors()
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = CGRect(x: 0, y: 0, width: 108, height: 8)
        accent.layer.insertSublayer(gradient, at: 0)
        view.addSubview(accent)
        NSLayoutConstraint.activate([
            accent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accent.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            accent.widthAnchor.constraint(equalToConstant: 108),
            accent.heightAnchor.constraint(equalToConstant: 8)
        ])

        // --- Main Stack ---
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: accent.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        // --- Emoji/Icon ---
        let iconLabel = UILabel()
        iconLabel.text = statIcon()
        iconLabel.font = .systemFont(ofSize: 44)
        iconLabel.textAlignment = .center
        stack.addArrangedSubview(iconLabel)

        // --- Title ---
        let titleLabel = UILabel()
        titleLabel.text = titleStr
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        // --- Description ---
        let descLabel = UILabel()
        descLabel.text = msg
        descLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descLabel.textColor = .label
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        stack.addArrangedSubview(descLabel)

        // --- Chips Section ---
        if !dateStrings.isEmpty {
            let chipStack = UIStackView()
            chipStack.axis = .horizontal
            chipStack.spacing = 14
            chipStack.alignment = .center
            chipStack.translatesAutoresizingMaskIntoConstraints = false

            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none

            for (i, dateStr) in dateStrings.enumerated() {
                let date = Habit.dateFromString(dateStr)
                let pretty = date != nil ? df.string(from: date!) : dateStr
                let chip = UILabel()
                chip.text = pretty
                chip.font = .systemFont(ofSize: 17, weight: .semibold)
                chip.textAlignment = .center
                chip.backgroundColor = .white.withAlphaComponent(0.95)
                chip.textColor = .label
                chip.layer.cornerRadius = 13
                chip.layer.borderWidth = 1.2
                chip.layer.borderColor = accentColor.withAlphaComponent(0.45).cgColor
                chip.layer.masksToBounds = true
                chip.widthAnchor.constraint(greaterThanOrEqualToConstant: 110).isActive = true
                chip.heightAnchor.constraint(equalToConstant: 40).isActive = true
                chip.alpha = 0
                // Soft shadow on chip for polish
                chip.layer.shadowColor = accentColor.withAlphaComponent(0.15).cgColor
                chip.layer.shadowOpacity = 1
                chip.layer.shadowOffset = CGSize(width: 0, height: 2)
                chip.layer.shadowRadius = 7
                chipStack.addArrangedSubview(chip)

                UIView.animate(withDuration: 0.45, delay: Double(i)*0.08, options: [.curveEaseOut], animations: {
                    chip.alpha = 1
                }, completion: nil)
            }
            stack.addArrangedSubview(chipStack)
        } else {
            let noDatesLabel = UILabel()
            noDatesLabel.text = "No dates found for this streak."
            noDatesLabel.font = .systemFont(ofSize: 15, weight: .regular)
            noDatesLabel.textColor = .secondaryLabel
            noDatesLabel.textAlignment = .center
            stack.addArrangedSubview(noDatesLabel)
        }
    }

    private func statIcon() -> String {
        switch statType {
        case .streak: return "🔥"
        case .best:   return "⚡️"
        case .done:   return "✅"
        }
    }
    private func accentBarColors() -> [CGColor] {
        switch statType {
        case .streak:
            return [UIColor.systemRed.withAlphaComponent(0.8).cgColor,
                    UIColor.systemOrange.withAlphaComponent(0.8).cgColor]
        case .best:
            return [UIColor.systemOrange.withAlphaComponent(0.78).cgColor, UIColor.systemYellow.withAlphaComponent(0.65).cgColor]
        case .done:
            return [UIColor.systemGreen.withAlphaComponent(0.9).cgColor, UIColor.systemGreen.withAlphaComponent(0.5).cgColor]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sheet = self.sheetPresentationController {
            let baseHeight: CGFloat = 260
            let dateRows = CGFloat(max(1, (dateStrings.count+2)/3))
            let sheetHeight = baseHeight + dateRows*45
            sheet.detents = [
                .custom(resolver: { _ in min(sheetHeight, UIScreen.main.bounds.height*0.56) })
            ]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 28
        }
    }
}

// MARK: - Helper Extensions

private extension Habit {
    func currentStreakAndDates() -> (Int, [String]) {
        let calendar = Calendar.current
        let today = Date()
        let doneSet = Set(doneDates.compactMap { $0.value ? $0.key : nil })
        var streak = 0
        var streakDates: [String] = []
        for i in 0..<365 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { break }
            let str = Habit.dateString(for: day)
            if doneSet.contains(str) {
                streak += 1
                streakDates.append(str)
            } else if i == 0 { return (0, []) }
            else { break }
        }
        return (streak, streakDates.reversed())
    }
    func bestStreakAndDates() -> (Int, [String]) {
        let sortedKeys = doneDates.keys.sorted()
        var best = 0, current = 0
        var bestDates: [String] = []
        var currentDates: [String] = []
        let calendar = Calendar.current
        var lastDay: Date? = nil
        for key in sortedKeys {
            guard doneDates[key] == true else { continue }
            let date = Habit.dateFromString(key)
            if let last = lastDay, let d = date {
                let delta = calendar.dateComponents([.day], from: last, to: d ?? Date()).day ?? 0
                if delta == 1 {
                    current += 1
                    currentDates.append(key)
                } else {
                    current = 1
                    currentDates = [key]
                }
            } else {
                current = 1
                currentDates = [key]
            }
            if current > best {
                best = current
                bestDates = currentDates
            }
            lastDay = date
        }
        return (best, bestDates)
    }
    static func dateFromString(_ string: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: string)
    }

}

private extension UIColor {
    var isLight: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        // Perceived luminance
        return (r*299 + g*587 + b*114)/1000 > 0.72
    }
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
