import UIKit

protocol AddHabitViewControllerDelegate: AnyObject {
    func didAddHabit()
}

class AddHabitViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let habitTitleTextField = ModernTextField(placeholder: "Habit Title")
    private let habitDescriptionTextField = ModernTextField(placeholder: "Description (optional)")
    private let frequencyLabel = UILabel()
    private let frequencySegmentedControl = UISegmentedControl(items: ["Daily", "Weekly", "Monthly", "Custom"])
    private var customFrequencyData: (days: [Int], times: [Date], reminderEnabled: Bool)?
    private let colorLabel = UILabel()
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let iconLabel = UILabel()
    private let iconCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let buddiesLabel = UILabel()
    private let buddiesButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    // Data
    private let colors = [
        "#FF6B6B", "#4ECDC4", "#FFE66D", "#1A535C", "#FF9F1C",
        "#3D5A80", "#E07A5F", "#81B29A", "#F2CC8F", "#6B705C"
    ]
    private let icons = [
        "heart.fill", "star.fill", "flag.fill", "bolt.fill", "book.fill",
        "moon.fill", "drop.fill", "flame.fill", "leaf.fill", "sun.max.fill",
        "gamecontroller.fill", "music.note", "swift", "cart.fill", "airplane"
    ]
    private var selectedColorIndex = 0
    private var selectedIconIndex = 0
    private var selectedFrequency: HabitFrequency = .daily
    private var selectedBuddies: [User] = []
    
    weak var delegate: AddHabitViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        contentView.addSubview(headerView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Create New Habit"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)
        
        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.contentVerticalAlignment = .fill
        closeButton.contentHorizontalAlignment = .fill
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        headerView.addSubview(closeButton)
        
        // Habit Title TextField
        habitTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(habitTitleTextField)
        
        // Habit Description TextField
        habitDescriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(habitDescriptionTextField)
        
        // Frequency Label
        frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyLabel.text = "Frequency"
        frequencyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(frequencyLabel)
        
        // Frequency Segmented Control
        frequencySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        frequencySegmentedControl.selectedSegmentIndex = 0
        frequencySegmentedControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        contentView.addSubview(frequencySegmentedControl)
        
        // Color Label
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.text = "Color"
        colorLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(colorLabel)
        
        // Color Collection View
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(colorCollectionView)
        
        // Icon Label
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = "Icon"
        iconLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(iconLabel)
        
        // Icon Collection View
        iconCollectionView.translatesAutoresizingMaskIntoConstraints = false
        iconCollectionView.backgroundColor = .clear
        iconCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(iconCollectionView)
        
        // Buddies Label
        buddiesLabel.translatesAutoresizingMaskIntoConstraints = false
        buddiesLabel.text = "Share with Friends"
        buddiesLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(buddiesLabel)
        
        // Buddies Button
        buddiesButton.translatesAutoresizingMaskIntoConstraints = false
        buddiesButton.setTitle("Select Buddies", for: .normal)
        buddiesButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        buddiesButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        buddiesButton.backgroundColor = UIColor.systemGray6
        buddiesButton.layer.cornerRadius = 10
        buddiesButton.tintColor = .systemBlue
        buddiesButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        buddiesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        buddiesButton.addTarget(self, action: #selector(addBuddyTapped), for: .touchUpInside)
        contentView.addSubview(buddiesButton)
        
        // Create Button
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitle("Create Habit", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        createButton.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        contentView.addSubview(createButton)
        
        // Layout Constraints
        let headerHeight: CGFloat = 150
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            habitTitleTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 30),
            habitTitleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            habitTitleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            habitTitleTextField.heightAnchor.constraint(equalToConstant: 60),
            
            habitDescriptionTextField.topAnchor.constraint(equalTo: habitTitleTextField.bottomAnchor, constant: 24),
            habitDescriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            habitDescriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            habitDescriptionTextField.heightAnchor.constraint(equalToConstant: 60),
            
            frequencyLabel.topAnchor.constraint(equalTo: habitDescriptionTextField.bottomAnchor, constant: 32),
            frequencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            frequencySegmentedControl.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 16),
            frequencySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            frequencySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            frequencySegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            colorLabel.topAnchor.constraint(equalTo: frequencySegmentedControl.bottomAnchor, constant: 32),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            iconLabel.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 32),
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            iconCollectionView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 16),
            iconCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            iconCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            buddiesLabel.topAnchor.constraint(equalTo: iconCollectionView.bottomAnchor, constant: 32),
            buddiesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            buddiesButton.topAnchor.constraint(equalTo: buddiesLabel.bottomAnchor, constant: 16),
            buddiesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            createButton.topAnchor.constraint(equalTo: buddiesButton.bottomAnchor, constant: 40),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Apply gradient to header view
        DispatchQueue.main.async {
            self.headerView.applyGradient(
                colors: [
                    UIColor(hex: "#4F46E5") ?? .systemBlue,
                    UIColor(hex: "#8B5CF6") ?? .systemIndigo
                ],
                startPoint: CGPoint(x: 0, y: 0),  // Top left
                endPoint: CGPoint(x: 1, y: 1)     // Bottom right
            )
        }
    }
    
    private func setupCollectionViews() {
        // Register cells
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        iconCollectionView.register(IconCollectionViewCell.self, forCellWithReuseIdentifier: "IconCell")
        
        // Set delegates and data sources
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        // Tag to differentiate between collections
        colorCollectionView.tag = 0
        iconCollectionView.tag = 1
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // Update the frequency changed method to show custom picker when "Custom" is selected
    @objc private func frequencyChanged() {
        switch frequencySegmentedControl.selectedSegmentIndex {
        case 0:
            selectedFrequency = .daily
        case 1:
            selectedFrequency = .weekly
        case 2:
            selectedFrequency = .monthly
        case 3:
            selectedFrequency = .custom
            // Show custom frequency picker
            showCustomFrequencyPicker()
        default:
            selectedFrequency = .daily
        }
    }
    
    @objc private func addBuddyTapped() {
        let buddySelectorVC = BuddySelectorViewController(selectedBuddies: selectedBuddies)
        buddySelectorVC.delegate = self
        navigationController?.pushViewController(buddySelectorVC, animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = habitTitleTextField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter a habit title")
            habitTitleTextField.shake() // Add visual feedback
            return
        }
        
        // Validate custom frequency is set if that option is selected
        if selectedFrequency == .custom && customFrequencyData == nil {
            showCustomFrequencyPicker()
            return
        }
        
        let description = habitDescriptionTextField.text
        let color = colors[selectedColorIndex]
        let icon = icons[selectedIconIndex]
        let buddyIds = selectedBuddies.map { $0.id }
        
        // Add haptic feedback before creating
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Create habit with custom data if needed
        var additionalData: [String: Any]? = nil
        
        if let customData = customFrequencyData {
            additionalData = [
                "customDays": customData.days,
                "customTimes": customData.times.map { $0.timeIntervalSince1970 },
                "reminderEnabled": customData.reminderEnabled
            ]
        }
        
        // Create habit
        HabitService.shared.createHabit(
            title: title,
            description: description,
            frequency: selectedFrequency,
            color: color,
            icon: icon,
            buddyIds: buddyIds.isEmpty ? nil : buddyIds,
            additionalData: additionalData
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.delegate?.didAddHabit()
                    self?.dismiss(animated: true)
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showCustomFrequencyPicker() {
        let customFrequencyVC = CustomFrequencyViewController()
        customFrequencyVC.delegate = self
        
        let navController = UINavigationController(rootViewController: customFrequencyVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension AddHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return colors.count
        } else {
            return icons.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let colorHex = colors[indexPath.item]
            cell.configure(with: colorHex, isSelected: indexPath.item == selectedColorIndex)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let iconName = icons[indexPath.item]
            cell.configure(with: iconName, isSelected: indexPath.item == selectedIconIndex)
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Add haptic feedback
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        if collectionView.tag == 0 {
            selectedColorIndex = indexPath.item
            colorCollectionView.reloadData()
        } else {
            selectedIconIndex = indexPath.item
            iconCollectionView.reloadData()
        }
    }
}

// MARK: - BuddySelectorViewControllerDelegate
extension AddHabitViewController: BuddySelectorViewControllerDelegate {
    func didSelectBuddies(_ buddies: [User]) {
        selectedBuddies = buddies
        
        // Update buddy button label based on selection
        if buddies.isEmpty {
            buddiesButton.setTitle("Select Buddies", for: .normal)
        } else {
            buddiesButton.setTitle("\(buddies.count) Buddy(ies) Selected", for: .normal)
        }
    }
}

// MARK: - CustomFrequencyViewControllerDelegate
extension AddHabitViewController: CustomFrequencyViewControllerDelegate {
    func didSaveCustomFrequency(selectedDays: [Int], selectedTimes: [Date], reminderEnabled: Bool) {
        // Store the custom frequency data
        customFrequencyData = (selectedDays, selectedTimes, reminderEnabled)
        
        // Update UI to show custom frequency is set
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let selectedDayNames = selectedDays.map { dayNames[$0] }.joined(separator: ", ")
        
        // You could add a label to show the selected custom frequency
        // For example:
        // customFrequencyLabel.text = "Custom: \(selectedDayNames)"
        // customFrequencyLabel.isHidden = false
        
        // Update create button to show custom is set
        createButton.setTitle("Create Habit (Custom Schedule)", for: .normal)
    }
}
