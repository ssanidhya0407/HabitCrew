//
//  ProfileViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let emailLabel = UILabel()
    private let statsStackView = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Data
    private let sections = ["Account", "App Settings", "About"]
    private let accountItems = ["Edit Profile", "Change Password"]
    private let appSettingsItems = ["Notifications", "Theme", "Privacy"]
    private let aboutItems = ["Help", "Terms of Service", "Privacy Policy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Profile Image View
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.backgroundColor = .systemGray4
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.tintColor = .white
        view.addSubview(profileImageView)
        
        // Username Label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        // Email Label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        view.addSubview(emailLabel)
        
        // Stats Stack View
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 20
        view.addSubview(statsStackView)
        
        // Add stat views
        let habitsStatView = createStatView(value: "0", label: "Habits")
        let streaksStatView = createStatView(value: "0", label: "Streaks")
        let friendsStatView = createStatView(value: "0", label: "Friends")
        
        statsStackView.addArrangedSubview(habitsStatView)
        statsStackView.addArrangedSubview(streaksStatView)
        statsStackView.addArrangedSubview(friendsStatView)
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        // Add logout button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            tableView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createStatView(value: String, label: String) -> UIView {
        let containerView = UIView()
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.text = value
        valueLabel.textAlignment = .center
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.text = label
        textLabel.textColor = .secondaryLabel
        textLabel.textAlignment = .center
        
        containerView.addSubview(valueLabel)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    private func loadUserData() {
        guard let currentUser = AuthService.shared.currentUser else {
            // Show login screen if not logged in
            return
        }
        
        usernameLabel.text = currentUser.username
        emailLabel.text = currentUser.email
        
        // Load statistics
        HabitService.shared.getHabits { [weak self] result in
            switch result {
            case .success(let habits):
                DispatchQueue.main.async {
                    // Update habits count
                    if let habitsView = self?.statsStackView.arrangedSubviews[0].subviews.first as? UILabel {
                        habitsView.text = "\(habits.count)"
                    }
                    
                    // Calculate total streaks
                    let totalStreaks = habits.reduce(0) { $0 + $1.streak }
                    if let streaksView = self?.statsStackView.arrangedSubviews[1].subviews.first as? UILabel {
                        streaksView.text = "\(totalStreaks)"
                    }
                }
                
            case .failure(let error):
                print("Error loading habits: \(error.localizedDescription)")
            }
        }
        
        FriendsService.shared.getFriends { [weak self] result in
            switch result {
            case .success(let friends):
                DispatchQueue.main.async {
                    // Update friends count
                    if let friendsView = self?.statsStackView.arrangedSubviews[2].subviews.first as? UILabel {
                        friendsView.text = "\(friends.count)"
                    }
                }
                
            case .failure(let error):
                print("Error loading friends: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func logoutTapped() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            AuthService.shared.signOut { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        // Present login screen
                        let loginVC = LoginViewController()
                        let navController = UINavigationController(rootViewController: loginVC)
                        navController.modalPresentationStyle = .fullScreen
                        self?.present(navController, animated: true)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        })
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return accountItems.count
        case 1: return appSettingsItems.count
        case 2: return aboutItems.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        // Configure cell based on section and row
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = accountItems[indexPath.row]
        case 1:
            cell.textLabel?.text = appSettingsItems[indexPath.row]
        case 2:
            cell.textLabel?.text = aboutItems[indexPath.row]
        default:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle cell selection
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let editProfileVC = EditProfileViewController()
                navigationController?.pushViewController(editProfileVC, animated: true)
            case 1:
                let changePasswordVC = ChangePasswordViewController()
                navigationController?.pushViewController(changePasswordVC, animated: true)
            default:
                break
            }
        case 1:
            // Handle app settings taps
            let settingName = appSettingsItems[indexPath.row]
            let settingsVC = SettingsViewController(title: settingName)
            navigationController?.pushViewController(settingsVC, animated: true)
        case 2:
            // Handle about taps
            let aboutName = aboutItems[indexPath.row]
            let aboutVC = AboutViewController(title: aboutName)
            navigationController?.pushViewController(aboutVC, animated: true)
        default:
            break
        }
    }
}