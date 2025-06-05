//
//  EditHabitViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol EditHabitViewControllerDelegate: AnyObject {
    func didUpdateHabit(_ habit: Habit)
    func didDeleteHabit(_ habitId: String)
}

class EditHabitViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let frequencySegmentedControl = UISegmentedControl(items: ["Daily", "Weekly", "Monthly", "Custom"])
    private let colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let iconCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let addBuddyButton = UIButton(type: .system)
    private let updateButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
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
    private var selectedColorIndex: Int
    private var selectedIconIndex: Int
    private var selectedFrequency: HabitFrequency
    private var selectedBuddies: [User] = []
    
    private var habit: Habit
    weak var delegate: EditHabitViewControllerDelegate?
    
    init(habit: Habit) {
        self.habit = habit
        
        // Initialize selected indices
        self.selectedColorIndex = colors.firstIndex(of: habit.color) ?? 0
        self.selectedIconIndex = icons.firstIndex(of: habit.icon) ?? 0
        self.selectedFrequency = habit.frequency
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
        loadBuddies()
        populateFields()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Edit Habit"
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title Text Field
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "Habit title"
        titleTextField.borderStyle = .roundedRect
        contentView.addSubview(titleTextField)
        
        // Description Text Field
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.placeholder = "Description (optional)"
        descriptionTextField.borderStyle = .roundedRect
        contentView.addSubview(descriptionTextField)
        
        // Frequency Segmented Control
        frequencySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        frequencySegmentedControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        contentView.addSubview(frequencySegmentedControl)
        
        // Color Collection View Label
        let colorLabel = UILabel()
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.text = "Select a Color"
        colorLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(colorLabel)
        
        // Color Collection View
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .horizontal
        colorLayout.itemSize = CGSize(width: 40, height: 40)
        colorLayout.minimumInteritemSpacing = 10
        
        colorCollectionView.collectionViewLayout = colorLayout
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.backgroundColor = .systemBackground
        colorCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(colorCollectionView)
        
        // Icon Collection View Label
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = "Select an Icon"
        iconLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(iconLabel)
        
        // Icon Collection View
        let iconLayout = UICollectionViewFlowLayout()
        iconLayout.scrollDirection = .horizontal
        iconLayout.itemSize = CGSize(width: 40, height: 40)
        iconLayout.minimumInteritemSpacing = 10
        
        iconCollectionView.collectionViewLayout = iconLayout
        iconCollectionView.translatesAutoresizingMaskIntoConstraints = false
        iconCollectionView.backgroundColor = .systemBackground
        iconCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(iconCollectionView)
        
        // Add Buddy Button
        addBuddyButton.translatesAutoresizingMaskIntoConstraints = false
        addBuddyButton.setTitle("Edit Buddies", for: .normal)
        addBuddyButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        addBuddyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addBuddyButton.backgroundColor = .systemGray6
        addBuddyButton.layer.cornerRadius = 8
        addBuddyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        addBuddyButton.addTarget(self, action: #selector(addBuddyTapped), for: .touchUpInside)
        contentView.addSubview(addBuddyButton)
        
        // Update Button
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.setTitle("Update Habit", for: .normal)
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        updateButton.backgroundColor = .systemBlue
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.layer.cornerRadius = 10
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        contentView.addSubview(updateButton)
        
        // Delete Button
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete Habit", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            frequencySegmentedControl.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            frequencySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            frequencySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            colorLabel.topAnchor.constraint(equalTo: frequencySegmentedControl.bottomAnchor, constant: 20),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 10),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            iconLabel.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            iconCollectionView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 10),
            iconCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            iconCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            addBuddyButton.topAnchor.constraint(equalTo: iconCollectionView.bottomAnchor, constant: 30),
            addBuddyButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            updateButton.topAnchor.constraint(equalTo: addBuddyButton.bottomAnchor, constant: 30),
            updateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            updateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 20),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
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
    
    private func populateFields() {
        titleTextField.text = habit.title
        descriptionTextField.text = habit.description
        
        // Set frequency
        switch habit.frequency {
        case .daily:
            frequencySegmentedControl.selectedSegmentIndex = 0
        case .weekly:
            frequencySegmentedControl.selectedSegmentIndex = 1
        case .monthly:
            frequencySegmentedControl.selectedSegmentIndex = 2
        case .custom:
            frequencySegmentedControl.selectedSegmentIndex = 3
        }
        
        // Update buddy button text
        if let buddyIds = habit.buddyIds, !buddyIds.isEmpty {
            addBuddyButton.setTitle("\(buddyIds.count) Buddy(ies) Selected", for: .normal)
        }
    }
    
    private func loadBuddies() {
        // Load buddies data if available
        if let buddyIds = habit.buddyIds, !buddyIds.isEmpty {
            // In a real app, you would load the buddy data from the service
            // For now we'll just keep track of the IDs
            selectedBuddies = [] // This would be populated with actual User objects
        }
    }
    
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
            // In a real app, you might show a custom frequency selector here
        default:
            selectedFrequency = .daily
        }
    }
    
    @objc private func addBuddyTapped() {
        let buddySelectorVC = BuddySelectorViewController(selectedBuddies: selectedBuddies)
        buddySelectorVC.delegate = self
        navigationController?.pushViewController(buddySelectorVC, animated: true)
    }
    
    @objc private func updateButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter a habit title")
            return
        }
        
        // Update habit object
        habit.title = title
        habit.description = descriptionTextField.text
        habit.frequency = selectedFrequency
        habit.color = colors[selectedColorIndex]
        habit.icon = icons[selectedIconIndex]
        habit.buddyIds = selectedBuddies.map { $0.id }
        
        // Update habit in Firebase
        HabitService.shared.updateHabit(habit: habit) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.delegate?.didUpdateHabit(self!.habit)
                    self?.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func deleteButtonTapped() {
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Habit",
            message: "Are you sure you want to delete this habit? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            HabitService.shared.deleteHabit(habitId: self.habit.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.delegate?.didDeleteHabit(self.habit.id)
                        self.navigationController?.popViewController(animated: true)
                        
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension EditHabitViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
extension EditHabitViewController: BuddySelectorViewControllerDelegate {
    func didSelectBuddies(_ buddies: [User]) {
        selectedBuddies = buddies
        
        // Update buddy button label based on selection
        if buddies.isEmpty {
            addBuddyButton.setTitle("Edit Buddies", for: .normal)
        } else {
            addBuddyButton.setTitle("\(buddies.count) Buddy(ies) Selected", for: .normal)
        }
    }
}
