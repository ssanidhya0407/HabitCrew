//
//  CustomFrequencyViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol CustomFrequencyViewControllerDelegate: AnyObject {
    func didSaveCustomFrequency(selectedDays: [Int], selectedTimes: [Date], reminderEnabled: Bool)
}

class CustomFrequencyViewController: UIViewController {
    
    // UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let daysLabel = UILabel()
    private let daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 55, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let timesLabel = UILabel()
    private let timesTableView = UITableView()
    private let addTimeButton = UIButton(type: .system)
    
    private let reminderLabel = UILabel()
    private let reminderSwitch = UISwitch()
    private let reminderDescriptionLabel = UILabel()
    
    private let saveButton = UIButton(type: .system)
    
    // Data
    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var selectedDays: [Int] = [] // 0 = Sunday, 1 = Monday, etc.
    private var selectedTimes: [Date] = []
    private var reminderEnabled = true
    
    weak var delegate: CustomFrequencyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        view.addSubview(headerView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Custom Schedule"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Days Label
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.text = "Repeat On"
        daysLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(daysLabel)
        
        // Days Collection View
        daysCollectionView.translatesAutoresizingMaskIntoConstraints = false
        daysCollectionView.backgroundColor = .clear
        daysCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(daysCollectionView)
        
        // Times Label
        timesLabel.translatesAutoresizingMaskIntoConstraints = false
        timesLabel.text = "Reminder Times"
        timesLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(timesLabel)
        
        // Times Table View
        timesTableView.translatesAutoresizingMaskIntoConstraints = false
        timesTableView.backgroundColor = .clear
        timesTableView.separatorStyle = .none
        timesTableView.isScrollEnabled = false
        contentView.addSubview(timesTableView)
        
        // Add Time Button
        addTimeButton.translatesAutoresizingMaskIntoConstraints = false
        addTimeButton.setTitle("Add Time", for: .normal)
        addTimeButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        addTimeButton.tintColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        addTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addTimeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        addTimeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        addTimeButton.layer.cornerRadius = 10
        addTimeButton.layer.borderWidth = 1
        addTimeButton.layer.borderColor = UIColor.systemGray4.cgColor
        addTimeButton.addTarget(self, action: #selector(addTimeTapped), for: .touchUpInside)
        contentView.addSubview(addTimeButton)
        
        // Reminder Label
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        reminderLabel.text = "Enable Reminders"
        reminderLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(reminderLabel)
        
        // Reminder Switch
        reminderSwitch.translatesAutoresizingMaskIntoConstraints = false
        reminderSwitch.isOn = true
        reminderSwitch.onTintColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged), for: .valueChanged)
        contentView.addSubview(reminderSwitch)
        
        // Reminder Description Label
        reminderDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        reminderDescriptionLabel.text = "Receive notifications to help you stay on track with your habit."
        reminderDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        reminderDescriptionLabel.textColor = .secondaryLabel
        reminderDescriptionLabel.numberOfLines = 0
        contentView.addSubview(reminderDescriptionLabel)
        
        // Save Button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Schedule", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = UIColor(hex: "#4F46E5") ?? .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        
        // Layout Constraints
        let headerHeight: CGFloat = 120
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            daysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            daysCollectionView.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 16),
            daysCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            daysCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            daysCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            timesLabel.topAnchor.constraint(equalTo: daysCollectionView.bottomAnchor, constant: 32),
            timesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            timesTableView.topAnchor.constraint(equalTo: timesLabel.bottomAnchor, constant: 16),
            timesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            timesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            // Height will be updated dynamically based on content
            
            addTimeButton.topAnchor.constraint(equalTo: timesTableView.bottomAnchor, constant: 16),
            addTimeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            reminderLabel.topAnchor.constraint(equalTo: addTimeButton.bottomAnchor, constant: 32),
            reminderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            reminderSwitch.centerYAnchor.constraint(equalTo: reminderLabel.centerYAnchor),
            reminderSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            reminderDescriptionLabel.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 8),
            reminderDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            reminderDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            saveButton.topAnchor.constraint(equalTo: reminderDescriptionLabel.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Add default time
        let defaultTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        selectedTimes.append(defaultTime)
        
        // Add navigationBar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Apply gradient to header view
        DispatchQueue.main.async {
            self.headerView.applyGradient(
                colors: [
                    UIColor(hex: "#4F46E5") ?? .systemBlue,
                    UIColor(hex: "#8B5CF6") ?? .systemIndigo
                ],
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            )
        }
    }
    
    private func setupCollectionView() {
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.register(DaySelectionCell.self, forCellWithReuseIdentifier: "DaySelectionCell")
        
        // Default to weekdays
        selectedDays = [1, 2, 3, 4, 5] // Monday to Friday
    }
    
    private func setupTableView() {
        timesTableView.delegate = self
        timesTableView.dataSource = self
        timesTableView.register(TimeSelectionCell.self, forCellReuseIdentifier: "TimeSelectionCell")
        
        // Update table height based on content
        updateTableHeight()
    }
    
    private func updateTableHeight() {
        let height = CGFloat(selectedTimes.count * 60)
        
        // Update constraint
        let heightConstraint = timesTableView.constraints.first { $0.firstAttribute == .height } ??
                               timesTableView.heightAnchor.constraint(equalToConstant: height)
        
        heightConstraint.constant = height
        heightConstraint.isActive = true
        
        // Animate layout change
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func addTimeTapped() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        
        let alertController = UIAlertController(title: "Select Time", message: nil, preferredStyle: .actionSheet)
        
        // Add date picker to alert controller
        let vc = UIViewController()
        vc.view = datePicker
        vc.preferredContentSize = CGSize(width: 320, height: 200)
        alertController.setValue(vc, forKey: "contentViewController")
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.selectedTimes.append(datePicker.date)
            self?.timesTableView.reloadData()
            self?.updateTableHeight()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present on iPad properly
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = addTimeButton
            popoverController.sourceRect = addTimeButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    @objc private func reminderSwitchChanged() {
        reminderEnabled = reminderSwitch.isOn
    }
    
    @objc private func saveButtonTapped() {
        // Validate that days are selected
        if selectedDays.isEmpty {
            showAlert(title: "Select Days", message: "Please select at least one day for your habit.")
            return
        }
        
        // Validate that times are selected
        if reminderEnabled && selectedTimes.isEmpty {
            showAlert(title: "Select Times", message: "Please add at least one time for reminders.")
            return
        }
        
        // Save custom frequency settings
        delegate?.didSaveCustomFrequency(selectedDays: selectedDays, selectedTimes: selectedTimes, reminderEnabled: reminderEnabled)
        
        // Dismiss controller
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension CustomFrequencyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 // Days of the week
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DaySelectionCell", for: indexPath) as? DaySelectionCell else {
            return UICollectionViewCell()
        }
        
        let day = indexPath.item
        let isSelected = selectedDays.contains(day)
        cell.configure(with: dayNames[day], isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = indexPath.item
        
        // Toggle selection
        if let index = selectedDays.firstIndex(of: day) {
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(day)
        }
        
        // Update cell
        if let cell = collectionView.cellForItem(at: indexPath) as? DaySelectionCell {
            cell.setSelected(selectedDays.contains(day))
        }
        
        // Provide feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CustomFrequencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSelectionCell", for: indexPath) as? TimeSelectionCell else {
            return UITableViewCell()
        }
        
        let time = selectedTimes[indexPath.row]
        cell.configure(with: time)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - TimeSelectionCellDelegate
extension CustomFrequencyViewController: TimeSelectionCellDelegate {
    
    func didTapEditButton(for cell: TimeSelectionCell) {
        guard let indexPath = timesTableView.indexPath(for: cell) else { return }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = selectedTimes[indexPath.row]
        
        let alertController = UIAlertController(title: "Edit Time", message: nil, preferredStyle: .actionSheet)
        
        // Add date picker to alert controller
        let vc = UIViewController()
        vc.view = datePicker
        vc.preferredContentSize = CGSize(width: 320, height: 200)
        alertController.setValue(vc, forKey: "contentViewController")
        
        alertController.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            self?.selectedTimes[indexPath.row] = datePicker.date
            self?.timesTableView.reloadRows(at: [indexPath], with: .automatic)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present on iPad properly
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        present(alertController, animated: true)
    }
    
    func didTapDeleteButton(for cell: TimeSelectionCell) {
        guard let indexPath = timesTableView.indexPath(for: cell) else { return }
        
        selectedTimes.remove(at: indexPath.row)
        timesTableView.deleteRows(at: [indexPath], with: .automatic)
        updateTableHeight()
    }
}
