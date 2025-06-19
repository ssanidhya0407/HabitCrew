import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol AddHabitViewControllerDelegate: AnyObject {
    func didAddHabit(_ habit: Habit)
}


class AddHabitViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: AddHabitViewControllerDelegate?
    private let db = Firestore.firestore()
    private var selectedFriendOrGroup: String?  // The display name (for picker UI)
    private var selectedFriendOrGroupId: String? // The friend uid or group id (for saving to Firebase)
    private var selectedDate: Date?
    private var selectedTime: Date = Date()
    private var selectedIcon: String = "star.fill"
    private var selectedColor: UIColor = .systemBlue
    private var selectedDays: Set<Int> = [1,2,3,4,5,6,0]
    private var remindIfMiss: Bool = true

    private let gradientLayer = CAGradientLayer()
    private let decorativeBlob1 = UIView()
    private let decorativeBlob2 = UIView()

    // Friend and group lists (with mapping to uids)
    private var friendsSource: [(id: String, display: String)] = []
    private var groupsSource: [(id: String, display: String)] = []
    private var combinedSource: [(id: String?, display: String)] {
        var arr: [(String?, String)] = []
        if !friendsSource.isEmpty {
            arr.append((nil, "— Friends —"))
            arr += friendsSource.map { ($0.id, $0.display) }
        }
        if !groupsSource.isEmpty {
            arr.append((nil, "— Groups —"))
            arr += groupsSource.map { ($0.id, $0.display) }
        }
        return arr
    }

    // MARK: - UI Elements
    private let topTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Habit"
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor.label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.text = "Craft your goal, pick your style, and get reminders to stay on track!"
        label.font = UIFont.systemFont(ofSize: 16.5, weight: .regular)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Card
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 28
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        v.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.87)
        v.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.09).cgColor
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

    // MARK: - Fields
    private func themedTextField(_ placeholder: String, font: UIFont = .systemFont(ofSize: 17, weight: .regular)) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.font = font
        field.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ?
                UIColor(white: 0.19, alpha: 1) :
                UIColor(white: 0.96, alpha: 1)
        }
        field.textColor = .label
        field.layer.cornerRadius = 12
        field.layer.cornerCurve = .continuous
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ?
                UIColor(white: 0.28, alpha: 1) :
                UIColor(white: 0.87, alpha: 1)
        }.cgColor
        field.setLeftPaddingPoints(16)
        field.clearButtonMode = .whileEditing
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }
    private lazy var nameField = themedTextField("Habit name", font: .systemFont(ofSize: 18, weight: .semibold))
    private lazy var motivationField = themedTextField("Motivation (optional)")
    private lazy var friendField: UITextField = {
        let field = themedTextField("Accountability partner or group (optional)")
        field.tintColor = .systemPurple
        return field
    }()
    private let friendPicker = UIPickerView()

    // Customization Row
    private let iconColorRow = UIStackView()
    private let iconButton = UIButton(type: .system)
    private let colorButton = UIButton(type: .system)

    // Date & Time Row
    private let dateTimeRow = UIStackView()
    private let dateButton = UIButton(type: .system)
    private let timeButton = UIButton(type: .system)

    // Days Row (Apple style)
    private let daysStack = UIStackView()
    private var dayButtons: [UIButton] = []

    // Streak/Reminder
    private let streakRow = UIStackView()
    private let streakLabel = UILabel()
    private let remindToggle = UISwitch()
    private let remindLabel = UILabel()

    // Buttons
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Habit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        setupTopHeader()
        view.addSubview(cardView)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        cardView.addSubview(blurView)
        setupFormStack()
        friendPicker.delegate = self
        friendPicker.dataSource = self
        friendField.inputView = friendPicker
        friendField.delegate = self
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .clear

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 25),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: saveButton.topAnchor, constant: -28),
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        fetchFriendsAndGroups()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Firestore fetch for friends and groups (corrected for id mapping)
    private func fetchFriendsAndGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Friends: /users/{uid}/friends, documentID is the friend's UID
        db.collection("users").document(uid).collection("friends").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            self.friendsSource = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                if let displayName = data["displayName"] as? String, !displayName.isEmpty {
                    return (id: id, display: displayName)
                }
                if let name = data["name"] as? String, !name.isEmpty {
                    return (id: id, display: name)
                }
                if let email = data["email"] as? String, !email.isEmpty {
                    return (id: id, display: email)
                }
                return nil
            } ?? []
            // Groups: /groups, id is the group doc id, name is display
            self.db.collection("groups").whereField("memberUIDs", arrayContains: uid).getDocuments { [weak self] (groupSnap, error) in
                guard let self = self else { return }
                self.groupsSource = groupSnap?.documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    if let name = data["name"] as? String {
                        return (id: id, display: name)
                    }
                    return nil
                } ?? []
                DispatchQueue.main.async {
                    self.friendPicker.reloadAllComponents()
                }
            }
        }
    }

    // MARK: - Gradient & Blobs
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

    private func setupTopHeader() {
        view.addSubview(topTitleLabel)
        view.addSubview(descLabel)
        NSLayoutConstraint.activate([
            topTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 34),
            topTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            topTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -25),
            descLabel.topAnchor.constraint(equalTo: topTitleLabel.bottomAnchor, constant: 7),
            descLabel.leadingAnchor.constraint(equalTo: topTitleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
        ])
    }

    private func setupFormStack() {
        let formStack = UIStackView()
        formStack.axis = .vertical
        formStack.spacing = 14
        formStack.alignment = .fill
        formStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(formStack)
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 26),
            formStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            formStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -20)
        ])

        // Fields
        formStack.addArrangedSubview(nameField)
        formStack.addArrangedSubview(motivationField)
        formStack.addArrangedSubview(friendField)

        // Icon/Color (horizontal, light border, rounded)
        iconColorRow.axis = .horizontal
        iconColorRow.spacing = 12
        iconColorRow.alignment = .fill
        iconColorRow.distribution = .fillEqually
        iconColorRow.translatesAutoresizingMaskIntoConstraints = false
        iconButton.setImage(UIImage(systemName: selectedIcon), for: .normal)
        iconButton.tintColor = selectedColor
        iconButton.backgroundColor = UIColor.clear
        iconButton.layer.cornerRadius = 12
        iconButton.layer.borderWidth = 1
        iconButton.layer.borderColor = UIColor.systemGray3.cgColor
        iconButton.layer.masksToBounds = true
        iconButton.addTarget(self, action: #selector(pickIcon), for: .touchUpInside)
        iconButton.setTitle(" Icon", for: .normal)
        iconButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        iconButton.setTitleColor(.label, for: .normal)
        iconButton.contentHorizontalAlignment = .center
        iconButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        colorButton.setImage(UIImage(systemName: "paintpalette.fill"), for: .normal)
        colorButton.tintColor = selectedColor
        colorButton.backgroundColor = UIColor.clear
        colorButton.layer.cornerRadius = 12
        colorButton.layer.borderWidth = 1
        colorButton.layer.borderColor = UIColor.systemGray3.cgColor
        colorButton.layer.masksToBounds = true
        colorButton.addTarget(self, action: #selector(pickColor), for: .touchUpInside)
        colorButton.setTitle(" Color", for: .normal)
        colorButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        colorButton.setTitleColor(.label, for: .normal)
        colorButton.contentHorizontalAlignment = .center
        colorButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        iconColorRow.addArrangedSubview(iconButton)
        iconColorRow.addArrangedSubview(colorButton)
        formStack.addArrangedSubview(iconColorRow)

        // Date/Time (horizontal, modern Apple style)
        dateTimeRow.axis = .horizontal
        dateTimeRow.spacing = 12
        dateTimeRow.alignment = .fill
        dateTimeRow.distribution = .fillEqually
        dateTimeRow.translatesAutoresizingMaskIntoConstraints = false

        dateButton.setTitle("Start Date", for: .normal)
        dateButton.backgroundColor = UIColor.clear
        dateButton.setTitleColor(.label, for: .normal)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateButton.layer.cornerRadius = 12
        dateButton.layer.borderWidth = 1
        dateButton.layer.borderColor = UIColor.systemGray3.cgColor
        dateButton.layer.masksToBounds = true
        dateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        dateButton.addTarget(self, action: #selector(showDatePickerSheet), for: .touchUpInside)

        timeButton.setTitle("Time", for: .normal)
        timeButton.backgroundColor = UIColor.clear
        timeButton.setTitleColor(.label, for: .normal)
        timeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        timeButton.layer.cornerRadius = 12
        timeButton.layer.borderWidth = 1
        timeButton.layer.borderColor = UIColor.systemGray3.cgColor
        timeButton.layer.masksToBounds = true
        timeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        timeButton.addTarget(self, action: #selector(showTimePickerSheet), for: .touchUpInside)

        dateTimeRow.addArrangedSubview(dateButton)
        dateTimeRow.addArrangedSubview(timeButton)
        formStack.addArrangedSubview(dateTimeRow)

        // Days (Apple-style rounded selectors)
        let daysLabel = UILabel()
        daysLabel.text = "Repeat On"
        daysLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        daysLabel.textColor = .secondaryLabel
        formStack.addArrangedSubview(daysLabel)

        daysStack.axis = .horizontal
        daysStack.spacing = 7
        daysStack.alignment = .center
        daysStack.distribution = .fillEqually
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
        dayButtons = []
        for i in 0...6 {
            let btn = UIButton(type: .system)
            btn.setTitle(dayNames[i], for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15.5, weight: .semibold)
            btn.setTitleColor(selectedDays.contains(i) ? .white : .label, for: .normal)
            btn.backgroundColor = selectedDays.contains(i) ? selectedColor : UIColor.systemGray5
            btn.layer.cornerRadius = 17.5 // fully pill shaped
            btn.layer.borderWidth = selectedDays.contains(i) ? 0 : 1
            btn.layer.borderColor = UIColor.systemGray3.cgColor
            btn.tag = i
            btn.addTarget(self, action: #selector(toggleDay(_:)), for: .touchUpInside)
            btn.widthAnchor.constraint(equalToConstant: 35).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
            daysStack.addArrangedSubview(btn)
            dayButtons.append(btn)
        }
        daysStack.heightAnchor.constraint(equalToConstant: 35).isActive = true
        formStack.addArrangedSubview(daysStack)

        // Streak & Reminder (horizontal, clean)
        streakRow.axis = .horizontal
        streakRow.spacing = 8
        streakRow.alignment = .center
        streakRow.distribution = .fill
        streakRow.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.text = "🔥 Streak: \(selectedDays.count)x/week"
        streakLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        streakLabel.textColor = .systemOrange
        remindLabel.text = "Remind me if I miss"
        remindLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        remindLabel.textColor = .secondaryLabel
        remindToggle.isOn = remindIfMiss
        remindToggle.addTarget(self, action: #selector(toggleRemind(_:)), for: .valueChanged)
        streakRow.addArrangedSubview(streakLabel)
        streakRow.addArrangedSubview(remindLabel)
        streakRow.addArrangedSubview(remindToggle)
        formStack.addArrangedSubview(streakRow)
    }

    // MARK: - Actions


    @objc private func saveTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        guard let title = nameField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            nameField.shake()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let note: String? = nil
        guard let selectedDate = selectedDate else {
            dateButton.shake()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        let calendar = Calendar.current
        let combinedDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? Date()
        
        let habit = Habit(
            title: title,
            note: note,
            createdAt: Date(),
            friend: selectedFriendOrGroupId ?? "",
            schedule: combinedDate,
            icon: selectedIcon,
            colorHex: selectedColor.hexString,
            days: Array(selectedDays),
            motivation: motivationField.text,
            remindIfMiss: remindIfMiss
        )
        let habitData = habit.dictionary
        let habitId = habit.id
        
        saveButton.showLoading(true)
        db.collection("users").document(uid).collection("habits").document(habitId).setData(habitData) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.saveButton.showLoading(false)
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    return
                }
                self.delegate?.didAddHabit(habit)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                self.dismiss(animated: true)
            }
        }
    }
    


    @objc private func cancelTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss(animated: true)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func showDatePickerSheet() {
        let alert = UIAlertController(title: "Select Start Date", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        picker.date = selectedDate ?? Date()
        picker.frame = CGRect(x: 0, y: 22, width: alert.view.bounds.width-20, height: 160)
        picker.preferredDatePickerStyle = .wheels
        alert.view.addSubview(picker)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            self?.selectedDate = picker.date
            let df = DateFormatter()
            df.dateStyle = .medium
            self?.dateButton.setTitle(df.string(from: picker.date), for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = dateButton
            popover.sourceRect = dateButton.bounds
        }
        present(alert, animated: true)
    }

    @objc private func showTimePickerSheet() {
        let alert = UIAlertController(title: "Select Time", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.minuteInterval = 5
        picker.date = selectedTime
        picker.preferredDatePickerStyle = .wheels
        picker.frame = CGRect(x: 0, y: 22, width: alert.view.bounds.width-20, height: 160)
        alert.view.addSubview(picker)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            self?.selectedTime = picker.date
            let tf = DateFormatter()
            tf.timeStyle = .short
            self?.timeButton.setTitle(tf.string(from: picker.date), for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = timeButton
            popover.sourceRect = timeButton.bounds
        }
        present(alert, animated: true)
    }

    @objc private func toggleDay(_ sender: UIButton) {
        let idx = sender.tag
        if selectedDays.contains(idx) {
            selectedDays.remove(idx)
            sender.backgroundColor = UIColor.systemGray5
            sender.setTitleColor(.label, for: .normal)
            sender.layer.borderWidth = 1
        } else {
            selectedDays.insert(idx)
            sender.backgroundColor = selectedColor
            sender.setTitleColor(.white, for: .normal)
            sender.layer.borderWidth = 0
        }
        streakLabel.text = "🔥 Streak: \(selectedDays.count)x/week"
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    @objc private func toggleRemind(_ sender: UISwitch) {
        remindIfMiss = sender.isOn
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // --- Modern Icon & Color Selectors ---
    @objc private func pickIcon() {
        let sheet = IconPickerSheet()
        sheet.icons = ["star.fill", "flame.fill", "book.fill", "bolt.fill", "leaf.fill", "heart.fill", "moon.fill", "sun.max.fill", "cloud.fill", "bicycle"]
        sheet.selectedIcon = self.selectedIcon
        sheet.onSelect = { [weak self] iconName in
            guard let self = self else { return }
            self.selectedIcon = iconName
            self.iconButton.setImage(UIImage(systemName: iconName), for: .normal)
            self.iconButton.tintColor = self.selectedColor
        }
        sheet.modalPresentationStyle = .formSheet
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = iconButton
            pop.sourceRect = iconButton.bounds
            pop.permittedArrowDirections = .any
        }
        present(sheet, animated: true)
    }

    @objc private func pickColor() {
        let colors: [UIColor] = [
            .systemBlue, .systemPurple, .systemGreen,
            .systemRed, .systemYellow, .systemOrange,
            .systemTeal, .systemPink, .systemIndigo,
            .systemGray
        ]
        let sheet = ColorPickerSheet()
        sheet.colors = colors
        sheet.selectedColor = self.selectedColor
        sheet.onSelect = { [weak self] color in
            guard let self = self else { return }
            self.selectedColor = color
            self.iconButton.tintColor = color
            self.iconButton.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.95)
            self.colorButton.tintColor = color
            self.colorButton.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.95)
            for btn in self.dayButtons {
                if self.selectedDays.contains(btn.tag) {
                    btn.backgroundColor = color
                }
            }
        }
        sheet.modalPresentationStyle = .formSheet
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = colorButton
            pop.sourceRect = colorButton.bounds
            pop.permittedArrowDirections = .any
        }
        present(sheet, animated: true)
    }
}

// MARK: - UITextFieldDelegate for Friend/Group Picker

extension AddHabitViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return combinedSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return combinedSource[row].display
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let val = combinedSource[row]
        if val.id == nil {
            // section header
            return
        }
        selectedFriendOrGroup = val.display
        selectedFriendOrGroupId = val.id
        friendField.text = selectedFriendOrGroup
        friendField.layer.borderWidth = 0
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == friendField {
            if let sel = selectedFriendOrGroup, let idx = combinedSource.firstIndex(where: { $0.display == sel }) {
                friendPicker.selectRow(idx, inComponent: 0, animated: false)
            }
        }
    }
}
// MARK: - Loading Animation for Button
private extension UIButton {
    func showLoading(_ show: Bool) {
        if show {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = .white
            spinner.startAnimating()
            spinner.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            spinner.tag = 999
            addSubview(spinner)
            isUserInteractionEnabled = false
        } else {
            viewWithTag(999)?.removeFromSuperview()
            isUserInteractionEnabled = true
        }
    }
}

// MARK: - Shake for Invalid Input
private extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.44
        animation.values = [-12, 12, -8, 8, -4, 4, 0]
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - Left/Right Padding for UITextField
private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

// MARK: - UIColor to Hex String for Firebase
private extension UIColor {
    var hexString: String {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
