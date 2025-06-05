//
//  SettingsViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class SettingsViewController: UIViewController {
    
    // UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Data
    private let settingTitle: String
    private var settings: [[String: Any]] = []
    
    init(title: String) {
        self.settingTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSettings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = settingTitle
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        view.addSubview(tableView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureSettings() {
        switch settingTitle {
        case "Notifications":
            settings = [
                ["title": "Push Notifications", "type": "switch", "value": true],
                ["title": "Habit Reminders", "type": "switch", "value": true],
                ["title": "Friend Requests", "type": "switch", "value": true],
                ["title": "Messages", "type": "switch", "value": true],
                ["title": "Streak Alerts", "type": "switch", "value": true]
            ]
        case "Theme":
            settings = [
                ["title": "Dark Mode", "type": "switch", "value": false],
                ["title": "App Icon", "type": "disclosure", "value": "Default"],
                ["title": "Accent Color", "type": "disclosure", "value": "Blue"]
            ]
        case "Privacy":
            settings = [
                ["title": "Show Activity Status", "type": "switch", "value": true],
                ["title": "Show Streaks to Friends", "type": "switch", "value": true],
                ["title": "Allow Friend Requests", "type": "switch", "value": true],
                ["title": "Data & Privacy", "type": "disclosure"]
            ]
        default:
            settings = [
                ["title": "Sample Setting", "type": "switch", "value": false]
            ]
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settings[indexPath.row]
        
        if setting["type"] as? String == "switch" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            
            let title = setting["title"] as? String ?? ""
            let isOn = setting["value"] as? Bool ?? false
            
            cell.configure(title: title, isOn: isOn) { [weak self] isOn in
                // Update the setting value
                self?.settings[indexPath.row]["value"] = isOn
                
                // In a real app, you would save the setting to user defaults or a database
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            
            cell.textLabel?.text = setting["title"] as? String
            
            if let value = setting["value"] as? String {
                cell.detailTextLabel?.text = value
            }
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setting = settings[indexPath.row]
        
        if setting["type"] as? String == "disclosure" {
            // In a real app, you would navigate to a subscreen for this setting
            let alertController = UIAlertController(
                title: setting["title"] as? String,
                message: "This would navigate to a detailed screen for this setting",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        }
    }
}

// MARK: - SwitchTableViewCell
class SwitchTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    private var switchAction: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        // Toggle
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .systemBlue
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        contentView.addSubview(toggle)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -16),
            
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, isOn: Bool, action: @escaping (Bool) -> Void) {
        titleLabel.text = title
        toggle.isOn = isOn
        switchAction = action
    }
    
    @objc private func toggleChanged() {
        switchAction?(toggle.isOn)
    }
}