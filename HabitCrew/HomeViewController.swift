////
////  HomeViewController.swift
////  HabitCrew
////
////  Created by Sanidhya's MacBook Pro on 13/06/25.
////
//
//
//import UIKit
//import FirebaseAuth
//
//class HomeViewController: UIViewController {
//
//    // MARK: - UI Elements
//
//    private let greetingLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.textColor = .label
//        label.textAlignment = .left
//        label.numberOfLines = 2
//        label.text = "Welcome 👋"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let emailLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        label.textColor = .secondaryLabel
//        label.text = ""
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let profileButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Profile", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        button.setTitleColor(.systemBlue, for: .normal)
//        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        return button
//    }()
//
//    private let habitsButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("My Habits", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        button.setTitleColor(.systemPurple, for: .normal)
//        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.11)
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        return button
//    }()
//
//    private let analyticsButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Analytics", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        button.setTitleColor(.systemTeal, for: .normal)
//        button.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.11)
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        return button
//    }()
//
//    private let settingsButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Settings", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        button.setTitleColor(.systemGray, for: .normal)
//        button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.11)
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        return button
//    }()
//
//    private let logoutButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Log Out", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//        button.setTitleColor(.systemRed, for: .normal)
//        button.backgroundColor = UIColor.systemGray6
//        button.layer.cornerRadius = 10
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        return button
//    }()
//
//    private let habitCrewLogo: UIImageView = {
//        let iv = UIImageView(image: UIImage(systemName: "circle.grid.3x3.fill"))
//        iv.tintColor = UIColor.systemBlue.withAlphaComponent(0.83)
//        iv.contentMode = .scaleAspectFit
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//
//    private let appNameLabel: UILabel = {
//        let label = UILabel()
//        label.text = "HabitCrew"
//        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        label.textColor = UIColor.systemBlue.withAlphaComponent(0.90)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    // MARK: - Tab Bar Items
//
//    private lazy var tabBar: UITabBar = {
//        let tabBar = UITabBar()
//        tabBar.translatesAutoresizingMaskIntoConstraints = false
//        let habitsTab = UITabBarItem(title: "Habits", image: UIImage(systemName: "list.bullet.rectangle.portrait"), tag: 0)
//        let analyticsTab = UITabBarItem(title: "Analytics", image: UIImage(systemName: "chart.bar.xaxis"), tag: 1)
//        let profileTab = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
//        tabBar.items = [habitsTab, analyticsTab, profileTab]
//        tabBar.selectedItem = habitsTab
//        tabBar.backgroundColor = .systemBackground
//        tabBar.layer.cornerRadius = 18
//        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        tabBar.clipsToBounds = true
//        tabBar.tintColor = .systemBlue
//        tabBar.unselectedItemTintColor = .systemGray
//        tabBar.delegate = self
//        return tabBar
//    }()
//
//    // MARK: - View Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        navigationItem.hidesBackButton = true
//
//        setupBrandHeader()
//        setupUI()
//        setupTabBar()
//        populateUserInfo()
//    }
//
//    // MARK: - UI Setup
//
//    private func setupBrandHeader() {
//        let stack = UIStackView(arrangedSubviews: [habitCrewLogo, appNameLabel])
//        stack.axis = .horizontal
//        stack.alignment = .center
//        stack.spacing = 8
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(stack)
//        NSLayoutConstraint.activate([
//            habitCrewLogo.widthAnchor.constraint(equalToConstant: 26),
//            habitCrewLogo.heightAnchor.constraint(equalToConstant: 26),
//            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22)
//        ])
//    }
//
//    private func setupUI() {
//        view.addSubview(greetingLabel)
//        view.addSubview(emailLabel)
//
//        let buttonStack = UIStackView(arrangedSubviews: [
//            habitsButton, analyticsButton, profileButton, settingsButton
//        ])
//        buttonStack.axis = .vertical
//        buttonStack.spacing = 16
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(buttonStack)
//        view.addSubview(logoutButton)
//
//        NSLayoutConstraint.activate([
//            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
//            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
//            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
//
//            emailLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 6),
//            emailLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
//            emailLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
//
//            buttonStack.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 38),
//            buttonStack.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
//            buttonStack.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
//
//            logoutButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 32),
//            logoutButton.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
//            logoutButton.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor)
//        ])
//
//        habitsButton.addTarget(self, action: #selector(showHabits), for: .touchUpInside)
//        analyticsButton.addTarget(self, action: #selector(showAnalytics), for: .touchUpInside)
//        profileButton.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
//        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
//        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
//    }
//
//    private func setupTabBar() {
//        view.addSubview(tabBar)
//        NSLayoutConstraint.activate([
//            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            tabBar.heightAnchor.constraint(equalToConstant: 66)
//        ])
//    }
//
//    private func populateUserInfo() {
//        if let user = Auth.auth().currentUser {
//            let displayName = user.displayName ?? ""
//            let email = user.email ?? ""
//            greetingLabel.text = displayName.isEmpty ? "Welcome 👋" : "Welcome, \(displayName) 👋"
//            emailLabel.text = email
//        }
//    }
//
//    // MARK: - Actions
//
//    @objc private func logoutTapped() {
//        do {
//            try Auth.auth().signOut()
//            let welcomeVC = WelcomeViewController()
//            welcomeVC.modalPresentationStyle = .fullScreen
//            self.present(welcomeVC, animated: true, completion: nil)
//        } catch {
//            let alert = UIAlertController(title: "Logout Failed", message: error.localizedDescription, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//        }
//    }
//
//    @objc private func showHabits() {
//        let habitsVC = HabitsListViewController()
//        habitsVC.modalPresentationStyle = .fullScreen
//        self.present(habitsVC, animated: true)
//    }
//
//    @objc private func showAnalytics() {
//        let analyticsVC = AnalyticsViewController()
//        analyticsVC.modalPresentationStyle = .fullScreen
//        self.present(analyticsVC, animated: true)
//    }
//
//    @objc private func showProfile() {
//        let profileVC = ProfileViewController()
//        profileVC.modalPresentationStyle = .fullScreen
//        self.present(profileVC, animated: true)
//    }
//
//    @objc private func showSettings() {
//        let settingsVC = SettingsViewController()
//        settingsVC.modalPresentationStyle = .fullScreen
//        self.present(settingsVC, animated: true)
//    }
//}
//
//// MARK: - UITabBarDelegate
//
//extension HomeViewController: UITabBarDelegate {
//    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        switch item.tag {
//        case 0: showHabits()
//        case 1: showAnalytics()
//        case 2: showProfile()
//        default: break
//        }
//    }
//}
//
//// MARK: - Placeholder ViewControllers
//
//class HabitsListViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        let label = UILabel()
//        label.text = "Your Habits"
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
//
//class AnalyticsViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        let label = UILabel()
//        label.text = "Analytics"
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
//
//class ProfileViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        let label = UILabel()
//        label.text = "Profile"
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
//
//class SettingsViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        let label = UILabel()
//        label.text = "Settings"
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
