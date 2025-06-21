import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

// MARK: - Profile Stat Card (Apple Style, always visible label, with pop-in animation)
class ProfileStatView: UIView {
    private let iconView = UIImageView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private var animated = false

    init(icon: String, color: UIColor, title: String) {
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.text = "--"
        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    func setValue(_ value: Int) {
        valueLabel.text = "\(value)"
        if !animated {
            animated = true
            UIView.animate(withDuration: 0.6, delay: 0.05, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.4, options: [.curveEaseOut], animations: {
                self.alpha = 1
                self.transform = .identity
            })
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Weighted, Wide Habit Card Cell with animation and accessibility
class HabitCell: UITableViewCell {
    static let reuseID = "HabitCell"

    let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
    let iconBg = UIView()
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let privacyLabel = UILabel()
    let privacySwitch = UISwitch()

    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        // Card style: wide, weighted, glassmorphic with shadow
        container.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.90)
        container.layer.cornerRadius = 24
        container.clipsToBounds = true
        container.layer.masksToBounds = true
        container.layer.borderWidth = 0.8
        container.layer.borderColor = UIColor.systemGray5.withAlphaComponent(0.3).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        container.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        container.layer.shadowOpacity = 1
        container.layer.shadowRadius = 18
        container.layer.shadowOffset = CGSize(width: 0, height: 6)

        iconBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.14)
        iconBg.layer.cornerRadius = 20
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        privacyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        privacyLabel.textColor = .secondaryLabel
        privacyLabel.translatesAutoresizingMaskIntoConstraints = false

        privacySwitch.onTintColor = .systemGreen
        privacySwitch.translatesAutoresizingMaskIntoConstraints = false
        privacySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        privacySwitch.accessibilityLabel = "Toggle privacy for this habit"

        let leftStack = UIStackView(arrangedSubviews: [iconBg, titleLabel])
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 19
        leftStack.translatesAutoresizingMaskIntoConstraints = false

        iconBg.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
        ])

        let rightStack = UIStackView(arrangedSubviews: [privacyLabel, privacySwitch])
        rightStack.axis = .vertical
        rightStack.alignment = .center
        rightStack.spacing = 2
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        let mainRow = UIStackView(arrangedSubviews: [leftStack, rightStack])
        mainRow.axis = .horizontal
        mainRow.alignment = .center
        mainRow.spacing = 10
        mainRow.distribution = .equalSpacing
        mainRow.translatesAutoresizingMaskIntoConstraints = false

        container.contentView.addSubview(mainRow)
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            mainRow.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 20),
            mainRow.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -20),
            mainRow.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 19),
            mainRow.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -19),
        ])
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: 0, y: 24)
    }

    func animateIn(delay: Double) {
        UIView.animate(withDuration: 0.65, delay: delay, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.35, options: [.curveEaseOut], animations: {
            self.alpha = 1
            self.transform = .identity
        })
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        onToggle?(sender.isOn)
        privacyLabel.text = sender.isOn ? "Public" : "Private"
        UIAccessibility.post(notification: .announcement, argument: "Habit is now \(privacyLabel.text!)")
    }

    func configure(with habit: Habit) {
        iconView.image = UIImage(systemName: habit.icon) ?? UIImage(systemName: "star.fill")
        iconView.tintColor = UIColor(hex: habit.colorHex) ?? .systemBlue
        iconBg.backgroundColor = (UIColor(hex: habit.colorHex) ?? .systemBlue).withAlphaComponent(0.13)
        titleLabel.text = habit.title
        privacySwitch.isOn = habit.isPublic
        privacyLabel.text = habit.isPublic ? "Public" : "Private"
        titleLabel.accessibilityLabel = "Habit name: \(habit.title)"
        privacySwitch.accessibilityValue = privacyLabel.text
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Main ProfileViewController

class ProfileViewController: UIViewController, PHPickerViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    private let gradientLayer = CAGradientLayer()
    private let blob1 = UIView()
    private let blob2 = UIView()

    private let profileCard: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterialLight)
        let v = UIVisualEffectView(effect: blur)
        v.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.72)
        v.layer.cornerRadius = 30
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 54
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 54
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.systemGray4.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let avatarEditIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "camera.fill"))
        iv.tintColor = .white
        iv.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.88)
        iv.layer.cornerRadius = 17
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.preferredFont(forTextStyle: .title2)
        tf.textColor = .label
        tf.textAlignment = .center
        tf.placeholder = "Your Name"
        tf.layer.cornerRadius = 12
        tf.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.72)
        tf.layer.borderWidth = 0
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPaddingPoints(14)
        tf.setRightPaddingPoints(14)
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        return tf
    }()
    private let saveNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let friendsStat = ProfileStatView(icon: "person.2.fill", color: .systemPurple, title: "Friends")
    private let habitsStat = ProfileStatView(icon: "checkmark.seal.fill", color: .systemBlue, title: "Public Habits")

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.86)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    private let habitsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Habits"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let habitsTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsSelection = false
        table.register(HabitCell.self, forCellReuseIdentifier: HabitCell.reuseID)
        table.rowHeight = 92 // larger, weighted
        return table
    }()

    // MARK: - Data
    private var friends: [String] = []
    private var habits: [Habit] = []
    private var publicHabits: [Habit] { habits.filter { $0.isPublic } }

    private let db = Firestore.firestore()
    private var habitsListener: ListenerRegistration?
    private var friendsListener: ListenerRegistration?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        view.backgroundColor = .systemBackground
        setupBackground()
        setupUI()
        populateUserInfo()
        listenForFriends()
        listenForHabits()
        habitsTable.dataSource = self
        habitsTable.delegate = self
        nameField.delegate = self
        UIAccessibility.post(notification: .screenChanged, argument: "Profile screen loaded")
    }

    deinit {
        habitsListener?.remove()
        friendsListener?.remove()
    }

    // MARK: - Setup Design

    private func setupBackground() {
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.10).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.09).cgColor,
            UIColor.systemBackground.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.12, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.88, y: 1.0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)

        blob1.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
        blob1.layer.cornerRadius = 110
        blob1.translatesAutoresizingMaskIntoConstraints = false
        blob2.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.11)
        blob2.layer.cornerRadius = 95
        blob2.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(blob1)
        view.addSubview(blob2)
        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 200),
            blob1.heightAnchor.constraint(equalToConstant: 200),
            blob1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -80),
            blob2.widthAnchor.constraint(equalToConstant: 160),
            blob2.heightAnchor.constraint(equalToConstant: 160),
            blob2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 36),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60)
        ])
    }

    private func setupUI() {
        // Profile Card
        view.addSubview(profileCard)
        NSLayoutConstraint.activate([
            profileCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            profileCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            profileCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
        ])

        // Avatar
        profileCard.contentView.addSubview(avatarButton)
        avatarButton.addSubview(avatarView)
        avatarButton.addSubview(avatarEditIcon)
        NSLayoutConstraint.activate([
            avatarButton.topAnchor.constraint(equalTo: profileCard.contentView.topAnchor, constant: 18),
            avatarButton.centerXAnchor.constraint(equalTo: profileCard.contentView.centerXAnchor),
            avatarButton.widthAnchor.constraint(equalToConstant: 108),
            avatarButton.heightAnchor.constraint(equalToConstant: 108),
            avatarView.centerXAnchor.constraint(equalTo: avatarButton.centerXAnchor),
            avatarView.centerYAnchor.constraint(equalTo: avatarButton.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 108),
            avatarView.heightAnchor.constraint(equalToConstant: 108),
            avatarEditIcon.widthAnchor.constraint(equalToConstant: 34),
            avatarEditIcon.heightAnchor.constraint(equalToConstant: 34),
            avatarEditIcon.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor, constant: -3),
            avatarEditIcon.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: -3),
        ])
        avatarButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        avatarEditIcon.isHidden = false

        // Name, Save, Email, Stats
        profileCard.contentView.addSubview(nameField)
        profileCard.contentView.addSubview(saveNameButton)
        profileCard.contentView.addSubview(emailLabel)
        profileCard.contentView.addSubview(statsStack)
        profileCard.contentView.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 8),
            nameField.centerXAnchor.constraint(equalTo: profileCard.contentView.centerXAnchor),
            nameField.widthAnchor.constraint(equalToConstant: 220),
            nameField.heightAnchor.constraint(equalToConstant: 38),
            saveNameButton.centerXAnchor.constraint(equalTo: profileCard.contentView.centerXAnchor),
            saveNameButton.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 4),
            saveNameButton.widthAnchor.constraint(equalToConstant: 80),
            saveNameButton.heightAnchor.constraint(equalToConstant: 32),
            emailLabel.topAnchor.constraint(equalTo: saveNameButton.bottomAnchor, constant: 3),
            emailLabel.centerXAnchor.constraint(equalTo: profileCard.contentView.centerXAnchor),
            statsStack.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            statsStack.centerXAnchor.constraint(equalTo: profileCard.contentView.centerXAnchor),
            statsStack.leadingAnchor.constraint(equalTo: profileCard.contentView.leadingAnchor, constant: 14),
            statsStack.trailingAnchor.constraint(equalTo: profileCard.contentView.trailingAnchor, constant: -14),
            statsStack.heightAnchor.constraint(equalToConstant: 52),
            logoutButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 15),
            logoutButton.leadingAnchor.constraint(equalTo: profileCard.contentView.leadingAnchor, constant: 30),
            logoutButton.trailingAnchor.constraint(equalTo: profileCard.contentView.trailingAnchor, constant: -30),
            logoutButton.bottomAnchor.constraint(equalTo: profileCard.contentView.bottomAnchor, constant: -12)
        ])
        statsStack.addArrangedSubview(friendsStat)
        statsStack.addArrangedSubview(habitsStat)

        // Habits Table Section
        view.addSubview(habitsTitleLabel)
        view.addSubview(habitsTable)
        NSLayoutConstraint.activate([
            habitsTitleLabel.topAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: 28),
            habitsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            habitsTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            habitsTable.topAnchor.constraint(equalTo: habitsTitleLabel.bottomAnchor, constant: 8),
            habitsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            habitsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            habitsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6)
        ])
        saveNameButton.addTarget(self, action: #selector(saveNameTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        nameField.addTarget(self, action: #selector(nameEditingChanged), for: .editingChanged)
    }

    // MARK: - Data

    private func populateUserInfo() {
        if let user = Auth.auth().currentUser {
            nameField.text = user.displayName?.isEmpty == false ? user.displayName : "HabitCrew Member"
            emailLabel.text = user.email ?? ""
            let userDoc = db.collection("users").document(user.uid)
            userDoc.getDocument { [weak self] snapshot, error in
                if let urlString = snapshot?.data()?["photoURL"] as? String,
                   let url = URL(string: urlString) {
                    self?.setAvatarImage(from: url)
                }
            }
        }
    }

    private func listenForFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        friendsListener = db.collection("users").document(uid).collection("friends")
            .addSnapshotListener { [weak self] snap, err in
                let names = snap?.documents.compactMap { $0.data()["displayName"] as? String } ?? []
                self?.friends = names
                self?.friendsStat.setValue(names.count)
            }
    }

    private func listenForHabits() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        habitsListener = db.collection("users").document(uid).collection("habits")
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                let list = snap?.documents.compactMap { doc -> Habit? in
                    var data = doc.data()
                    data["id"] = doc.documentID
                    return Habit(from: data)
                } ?? []
                self.habits = list
                self.habitsStat.setValue(self.publicHabits.count)
                self.habitsTable.reloadData()
                self.animateHabitCells()
            }
    }

    // MARK: - Animations

    private func animateHabitCells() {
        let visible = habitsTable.visibleCells
        for (idx, cell) in visible.enumerated() {
            if let hcell = cell as? HabitCell {
                hcell.alpha = 0
                hcell.transform = CGAffineTransform(translationX: 0, y: 24)
                hcell.animateIn(delay: Double(idx) * 0.09)
            }
        }
    }

    // MARK: - Actions

    @objc private func changePhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider else { return }
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let img = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self.avatarView.image = img
                    self.saveAvatarImage(img)
                }
            }
        }
    }

    private func saveAvatarImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        let base64String = imageData.base64EncodedString()
        let userDoc = db.collection("users").document(uid)
        userDoc.setData(["photoData": base64String], merge: true)
    }

    private func setAvatarImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.avatarView.image = img
                }
            }
        }.resume()
    }

    @objc private func saveNameTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newName = nameField.text ?? ""
        db.collection("users").document(uid).setData(["displayName": newName], merge: true) { [weak self] err in
            if err == nil {
                self?.nameField.resignFirstResponder()
                UIView.animate(withDuration: 0.15) { self?.saveNameButton.alpha = 0 }
            }
        }
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
            changeRequest.displayName = newName
            changeRequest.commitChanges(completion: nil)
        }
    }

    @objc private func logoutTapped() {
        do {
            try Auth.auth().signOut()
            let welcomeVC = WelcomeViewController()
            welcomeVC.modalPresentationStyle = .fullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Logout Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func nameEditingChanged() {
        UIView.animate(withDuration: 0.16) { self.saveNameButton.alpha = 1 }
    }

    // MARK: - UITableViewDataSource & Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitCell.reuseID, for: indexPath) as! HabitCell
        cell.configure(with: habit)
        cell.onToggle = { [weak self] isPublic in
            self?.updateHabitPrivacy(habitId: habit.id, isPublic: isPublic)
        }
        return cell
    }

    private func updateHabitPrivacy(habitId: String, isPublic: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("habits").document(habitId)
            .setData(["isPublic": isPublic], merge: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNameTapped()
        return true
    }
}

// MARK: - UIColor hex helper
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

// MARK: - Padding for UITextField
private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

#Preview(){
    ProfileViewController()
}
