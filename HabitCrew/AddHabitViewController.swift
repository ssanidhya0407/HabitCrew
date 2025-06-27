import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol AddHabitViewControllerDelegate: AnyObject {
    func didAddHabit(_ habit: Habit)
    func didEditHabit(_ habit: Habit)
}

class AddHabitViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: AddHabitViewControllerDelegate?
    private let db = Firestore.firestore()
    private var selectedFriendOrGroup: String?
    private var selectedFriendOrGroupId: String?
    private var selectedDate: Date?
    private var selectedTime: Date = Date()
    private var selectedIcon: String = "star.fill"
    private var selectedColor: UIColor = .systemBlue
    private var selectedDays: Set<Int> = [1,2,3,4,5,6,0]
    private var remindIfMiss: Bool = true

    // Editing support
    private var editingHabit: Habit?

    // MARK: - Init for Add/Edit
    init(habitToEdit: Habit? = nil) {
        self.editingHabit = habitToEdit
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    // MARK: - UI Elements
    private let gradientLayer = CAGradientLayer()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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

    // Header View
    private let headerView = UIView()
    private let topTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Habit"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = UIColor.label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let descLabel: UILabel = {
        let label = UILabel()
        label.text = "Craft your goal, pick your style, and get reminders to stay on track!"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Form Cards
    private let basicInfoCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let scheduleCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let repeatCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let streakCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    // Form fields
    private lazy var nameField: UITextField = {
        return createTextField("Habit name", font: .systemFont(ofSize: 18, weight: .semibold))
    }()
    private lazy var motivationField = createTextField("Motivation (optional)")
    private lazy var friendField: UITextField = {
        let field = createTextField("Accountability partner or group (optional)")
        field.tintColor = .systemPurple
        return field
    }()
    private let friendPicker = UIPickerView()

    private let iconColorRow = UIStackView()
    private let iconButton = UIButton(type: .system)
    private let colorButton = UIButton(type: .system)
    private let dateTimeRow = UIStackView()
    private let dateButton = UIButton(type: .system)
    private let timeButton = UIButton(type: .system)
    private let daysStack = UIStackView()
    private var dayButtons: [UIButton] = []
    private let streakRow = UIStackView()
    private let streakLabel = UILabel()
    private let remindToggle = UISwitch()
    private let remindLabel = UILabel()
    
    // Action Buttons
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Habit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        button.layer.cornerRadius = 22
        button.layer.cornerCurve = .continuous
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupScrollView()
        setupHeaderView()
        setupFormCards()
        setupBasicInfoCard()
        setupScheduleCard()
        setupRepeatCard()
        setupStreakCard()
        setupButtons()
        
        friendPicker.delegate = self
        friendPicker.dataSource = self
        friendField.inputView = friendPicker
        friendField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        navigationController?.navigationBar.isHidden = true
        
        fetchFriendsAndGroups()
        applyEditingHabitIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        // Apply card styling
        applyCardStyling(to: basicInfoCard)
        applyCardStyling(to: scheduleCard)
        applyCardStyling(to: repeatCard)
        applyCardStyling(to: streakCard)
    }

    private func applyEditingHabitIfNeeded() {
        guard let habit = editingHabit else { return }
        topTitleLabel.text = "Edit Habit"
        saveButton.setTitle("Save Changes", for: .normal)
        nameField.text = habit.title
        motivationField.text = habit.motivation
        selectedFriendOrGroupId = habit.friend.isEmpty ? nil : habit.friend
        selectedDate = habit.schedule
        selectedTime = habit.schedule
        selectedIcon = habit.icon
        selectedColor = UIColor(hex: habit.colorHex) ?? .systemBlue
        selectedDays = Set(habit.days)
        remindIfMiss = habit.remindIfMiss ?? true

        iconButton.setImage(UIImage(systemName: selectedIcon), for: .normal)
        iconButton.tintColor = selectedColor
        colorButton.tintColor = selectedColor
        for (i, btn) in dayButtons.enumerated() {
            let isOn = selectedDays.contains(i)
            btn.backgroundColor = isOn ? selectedColor : UIColor.systemGray5
            btn.setTitleColor(isOn ? .white : .label, for: .normal)
        }
        let df = DateFormatter()
        df.dateStyle = .medium
        dateButton.setTitle(df.string(from: habit.schedule), for: .normal)
        let tf = DateFormatter()
        tf.timeStyle = .short
        timeButton.setTitle(tf.string(from: habit.schedule), for: .normal)
        remindToggle.isOn = remindIfMiss
    }
    
    // MARK: - UI Setup
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
    
    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        headerView.addSubview(topTitleLabel)
        headerView.addSubview(descLabel)
        headerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            topTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            topTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            topTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -12),
            
            closeButton.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            descLabel.topAnchor.constraint(equalTo: topTitleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: topTitleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            descLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        closeButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    private func setupFormCards() {
        basicInfoCard.translatesAutoresizingMaskIntoConstraints = false
        scheduleCard.translatesAutoresizingMaskIntoConstraints = false
        repeatCard.translatesAutoresizingMaskIntoConstraints = false
        streakCard.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(basicInfoCard)
        contentView.addSubview(scheduleCard)
        contentView.addSubview(repeatCard)
        contentView.addSubview(streakCard)
        
        NSLayoutConstraint.activate([
            basicInfoCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            basicInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            basicInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            scheduleCard.topAnchor.constraint(equalTo: basicInfoCard.bottomAnchor, constant: 16),
            scheduleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scheduleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            repeatCard.topAnchor.constraint(equalTo: scheduleCard.bottomAnchor, constant: 16),
            repeatCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            repeatCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            streakCard.topAnchor.constraint(equalTo: repeatCard.bottomAnchor, constant: 16),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBasicInfoCard() {
        let cardContent = UIView()
        cardContent.translatesAutoresizingMaskIntoConstraints = false
        basicInfoCard.contentView.addSubview(cardContent)
        
        let sectionTitle = createSectionTitle("Basic Information")
        
        cardContent.addSubview(sectionTitle)
        cardContent.addSubview(nameField)
        cardContent.addSubview(motivationField)
        cardContent.addSubview(friendField)
        
        // Icon and Color buttons
        iconColorRow.axis = .horizontal
        iconColorRow.spacing = 12
        iconColorRow.alignment = .fill
        iconColorRow.distribution = .fillEqually
        iconColorRow.translatesAutoresizingMaskIntoConstraints = false
        
        setupIconButton()
        setupColorButton()
        
        iconColorRow.addArrangedSubview(iconButton)
        iconColorRow.addArrangedSubview(colorButton)
        cardContent.addSubview(iconColorRow)
        
        NSLayoutConstraint.activate([
            cardContent.topAnchor.constraint(equalTo: basicInfoCard.contentView.topAnchor, constant: 16),
            cardContent.leadingAnchor.constraint(equalTo: basicInfoCard.contentView.leadingAnchor, constant: 16),
            cardContent.trailingAnchor.constraint(equalTo: basicInfoCard.contentView.trailingAnchor, constant: -16),
            cardContent.bottomAnchor.constraint(equalTo: basicInfoCard.contentView.bottomAnchor, constant: -16),
            
            sectionTitle.topAnchor.constraint(equalTo: cardContent.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            sectionTitle.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            
            nameField.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 16),
            nameField.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            
            motivationField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            motivationField.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            motivationField.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            
            friendField.topAnchor.constraint(equalTo: motivationField.bottomAnchor, constant: 12),
            friendField.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            friendField.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            
            iconColorRow.topAnchor.constraint(equalTo: friendField.bottomAnchor, constant: 12),
            iconColorRow.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            iconColorRow.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            iconColorRow.bottomAnchor.constraint(equalTo: cardContent.bottomAnchor)
        ])
    }
    
    private func setupScheduleCard() {
        let cardContent = UIView()
        cardContent.translatesAutoresizingMaskIntoConstraints = false
        scheduleCard.contentView.addSubview(cardContent)
        
        let sectionTitle = createSectionTitle("Schedule")
        
        dateTimeRow.axis = .horizontal
        dateTimeRow.spacing = 12
        dateTimeRow.alignment = .fill
        dateTimeRow.distribution = .fillEqually
        dateTimeRow.translatesAutoresizingMaskIntoConstraints = false
        
        setupDateButton()
        setupTimeButton()
        
        dateTimeRow.addArrangedSubview(dateButton)
        dateTimeRow.addArrangedSubview(timeButton)
        
        cardContent.addSubview(sectionTitle)
        cardContent.addSubview(dateTimeRow)
        
        NSLayoutConstraint.activate([
            cardContent.topAnchor.constraint(equalTo: scheduleCard.contentView.topAnchor, constant: 16),
            cardContent.leadingAnchor.constraint(equalTo: scheduleCard.contentView.leadingAnchor, constant: 16),
            cardContent.trailingAnchor.constraint(equalTo: scheduleCard.contentView.trailingAnchor, constant: -16),
            cardContent.bottomAnchor.constraint(equalTo: scheduleCard.contentView.bottomAnchor, constant: -16),
            
            sectionTitle.topAnchor.constraint(equalTo: cardContent.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            sectionTitle.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            
            dateTimeRow.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 16),
            dateTimeRow.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            dateTimeRow.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            dateTimeRow.bottomAnchor.constraint(equalTo: cardContent.bottomAnchor)
        ])
    }
    
    private func setupRepeatCard() {
        let cardContent = UIView()
        cardContent.translatesAutoresizingMaskIntoConstraints = false
        repeatCard.contentView.addSubview(cardContent)
        
        let sectionTitle = createSectionTitle("Repeat On")
        
        setupDaysStack()
        
        cardContent.addSubview(sectionTitle)
        cardContent.addSubview(daysStack)
        
        NSLayoutConstraint.activate([
            cardContent.topAnchor.constraint(equalTo: repeatCard.contentView.topAnchor, constant: 16),
            cardContent.leadingAnchor.constraint(equalTo: repeatCard.contentView.leadingAnchor, constant: 16),
            cardContent.trailingAnchor.constraint(equalTo: repeatCard.contentView.trailingAnchor, constant: -16),
            cardContent.bottomAnchor.constraint(equalTo: repeatCard.contentView.bottomAnchor, constant: -16),
            
            sectionTitle.topAnchor.constraint(equalTo: cardContent.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            sectionTitle.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            
            daysStack.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 16),
            daysStack.centerXAnchor.constraint(equalTo: cardContent.centerXAnchor),
            daysStack.bottomAnchor.constraint(equalTo: cardContent.bottomAnchor)
        ])
    }
    
    private func setupStreakCard() {
        let cardContent = UIView()
        cardContent.translatesAutoresizingMaskIntoConstraints = false
        streakCard.contentView.addSubview(cardContent)
        
        setupStreakRow()
        
        cardContent.addSubview(streakRow)
        
        NSLayoutConstraint.activate([
            cardContent.topAnchor.constraint(equalTo: streakCard.contentView.topAnchor, constant: 16),
            cardContent.leadingAnchor.constraint(equalTo: streakCard.contentView.leadingAnchor, constant: 16),
            cardContent.trailingAnchor.constraint(equalTo: streakCard.contentView.trailingAnchor, constant: -16),
            cardContent.bottomAnchor.constraint(equalTo: streakCard.contentView.bottomAnchor, constant: -16),
            
            streakRow.topAnchor.constraint(equalTo: cardContent.topAnchor),
            streakRow.leadingAnchor.constraint(equalTo: cardContent.leadingAnchor),
            streakRow.trailingAnchor.constraint(equalTo: cardContent.trailingAnchor),
            streakRow.bottomAnchor.constraint(equalTo: cardContent.bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        contentView.addSubview(saveButton)
        contentView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup UI Components
    private func createTextField(_ placeholder: String, font: UIFont = .systemFont(ofSize: 17, weight: .regular)) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.font = font
        field.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        field.textColor = .label
        field.layer.cornerRadius = 12
        field.layer.cornerCurve = .continuous
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }
    
    private func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupIconButton() {
        iconButton.setImage(UIImage(systemName: selectedIcon), for: .normal)
        iconButton.tintColor = selectedColor
        iconButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        iconButton.layer.cornerRadius = 12
        iconButton.layer.masksToBounds = true
        iconButton.addTarget(self, action: #selector(pickIcon), for: .touchUpInside)
        iconButton.setTitle(" Icon", for: .normal)
        iconButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        iconButton.setTitleColor(.label, for: .normal)
        iconButton.contentHorizontalAlignment = .center
        iconButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    private func setupColorButton() {
        colorButton.setImage(UIImage(systemName: "paintpalette.fill"), for: .normal)
        colorButton.tintColor = selectedColor
        colorButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        colorButton.layer.cornerRadius = 12
        colorButton.layer.masksToBounds = true
        colorButton.addTarget(self, action: #selector(pickColor), for: .touchUpInside)
        colorButton.setTitle(" Color", for: .normal)
        colorButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        colorButton.setTitleColor(.label, for: .normal)
        colorButton.contentHorizontalAlignment = .center
        colorButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    private func setupDateButton() {
        dateButton.setTitle("Start Date", for: .normal)
        dateButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        dateButton.setTitleColor(.label, for: .normal)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateButton.layer.cornerRadius = 12
        dateButton.layer.masksToBounds = true
        dateButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        dateButton.addTarget(self, action: #selector(showDatePickerSheet), for: .touchUpInside)
    }
    
    private func setupTimeButton() {
        timeButton.setTitle("Time", for: .normal)
        timeButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        timeButton.setTitleColor(.label, for: .normal)
        timeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        timeButton.layer.cornerRadius = 12
        timeButton.layer.masksToBounds = true
        timeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        timeButton.addTarget(self, action: #selector(showTimePickerSheet), for: .touchUpInside)
    }
    
    private func setupDaysStack() {
        daysStack.axis = .horizontal
        daysStack.spacing = 10
        daysStack.alignment = .center
        daysStack.distribution = .fillEqually
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
        dayButtons = []
        for i in 0...6 {
            let btn = UIButton(type: .system)
            btn.setTitle(dayNames[i], for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            btn.setTitleColor(selectedDays.contains(i) ? .white : .label, for: .normal)
            btn.backgroundColor = selectedDays.contains(i) ? selectedColor : UIColor.systemGray5
            btn.layer.cornerRadius = 22
            btn.tag = i
            btn.addTarget(self, action: #selector(toggleDay(_:)), for: .touchUpInside)
            btn.widthAnchor.constraint(equalToConstant: 44).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
            daysStack.addArrangedSubview(btn)
            dayButtons.append(btn)
        }
    }
    
    private func setupStreakRow() {
        streakRow.axis = .horizontal
        streakRow.spacing = 12
        streakRow.alignment = .center
        streakRow.distribution = .fill
        streakRow.translatesAutoresizingMaskIntoConstraints = false
        
        streakLabel.text = "🔥 Streak: \(selectedDays.count)x/week"
        streakLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        streakLabel.textColor = .systemOrange
        
        remindLabel.text = "Remind me if I miss"
        remindLabel.font = UIFont.systemFont(ofSize: 16)
        remindLabel.textColor = .secondaryLabel
        
        remindToggle.isOn = remindIfMiss
        remindToggle.onTintColor = selectedColor
        remindToggle.addTarget(self, action: #selector(toggleRemind(_:)), for: .valueChanged)
        
        streakRow.addArrangedSubview(streakLabel)
        streakRow.addArrangedSubview(UIView()) // Spacer
        streakRow.addArrangedSubview(remindLabel)
        streakRow.addArrangedSubview(remindToggle)
    }
    
    private func applyCardStyling(to card: UIVisualEffectView) {
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Apply a shadow to make it stand out better (done to the superview)
        card.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = 0.6
        card.clipsToBounds = false
    }

    // MARK: - Firestore fetch for friends and groups
    private func fetchFriendsAndGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
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

    // MARK: - Event Handlers
    @objc private func showDatePickerSheet() {
        let alert = UIAlertController(title: "Select Start Date", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        picker.date = selectedDate ?? Date()
        picker.frame = CGRect(x: 0, y: 22, width: alert.view.bounds.width-20, height: 160)
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
        picker.preferredDatePickerStyle = .wheels
        picker.minuteInterval = 5
        picker.date = selectedTime
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
        } else {
            selectedDays.insert(idx)
            sender.backgroundColor = selectedColor
            sender.setTitleColor(.white, for: .normal)
        }
        streakLabel.text = "🔥 Streak: \(selectedDays.count)x/week"
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func toggleRemind(_ sender: UISwitch) {
        remindIfMiss = sender.isOn
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

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
            self.colorButton.tintColor = color
            self.remindToggle.onTintColor = color
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

        var habit: Habit
        if let editing = editingHabit {
            // Edit existing
            habit = editing.copyWith(
                title: title,
                note: note,
                friend: selectedFriendOrGroupId ?? "",
                schedule: combinedDate,
                icon: selectedIcon,
                colorHex: selectedColor.hexString,
                days: Array(selectedDays),
                motivation: motivationField.text,
                remindIfMiss: remindIfMiss
            )
        } else {
            // Create new
            habit = Habit(
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
        }
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
                if self.editingHabit != nil {
                    self.delegate?.didEditHabit(habit)
                } else {
                    self.delegate?.didAddHabit(habit)
                }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                
                // Dismiss the view controller after successful save
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func cancelTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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

// MARK: - Habit copyWith for editing
private extension Habit {
    func copyWith(
        title: String? = nil,
        note: String? = nil,
        friend: String? = nil,
        schedule: Date? = nil,
        icon: String? = nil,
        colorHex: String? = nil,
        days: [Int]? = nil,
        motivation: String? = nil,
        remindIfMiss: Bool? = nil
    ) -> Habit {
        return Habit(
            id: self.id,
            title: title ?? self.title,
            note: note ?? self.note,
            createdAt: self.createdAt,
            friend: friend ?? self.friend,
            schedule: schedule ?? self.schedule,
            icon: icon ?? self.icon,
            colorHex: colorHex ?? self.colorHex,
            days: days ?? self.days,
            motivation: motivation ?? self.motivation,
            remindIfMiss: remindIfMiss ?? self.remindIfMiss
        )
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
            setTitle("", for: .normal)
            isUserInteractionEnabled = false
        } else {
            viewWithTag(999)?.removeFromSuperview()
            setTitle(self.title(for: .normal), for: .normal)
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

// MARK: - UIColor to Hex String for Firebase
private extension UIColor {
    var hexString: String {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
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
