import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var userProfile: UserProfile?
    private var friendsCount: Int = 0
    private var groupsCount: Int = 0
    private var habitsCount: Int = 0
    private var completionRate: Float = 0
    private var currentStreak: Int = 0
    
    private var friendsCountLabel: UILabel?
    private var groupsCountLabel: UILabel?
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    // Profile Header
    private let profileHeaderContainer = UIView()
    private let profileImageView = UIImageView()
    private let displayNameLabel = UILabel()
    private let emailLabel = UILabel()
    private let editProfileButton = UIButton(type: .system)
    
    // Stats Card
    private let statsCardContainer = UIView()
    private let statsCardBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    // Friends Card
    private let friendsCardContainer = UIView()
    private let friendsCardBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    // Achievements Card
    private let achievementsCardContainer = UIView()
    private let achievementsCardBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    // Settings Card
    private let settingsCardContainer = UIView()
    private let settingsCardBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    // About Card
    private let aboutCardContainer = UIView()
    private let aboutCardBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    // Date formatter for handling date strings
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupScrollView()
        setupUI()
        fetchUserProfile()
        fetchUserStats()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - UI Setup Methods
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
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    
    private func setupUI() {
        // Add navigation back button
        navigationItem.title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        
        // Setup all the card containers
        setupProfileHeader()
        setupStatsCard()
        setupFriendsCard()
        setupAchievementsCard()
        setupSettingsCard()
        setupAboutCard()
        
        // Set content view's bottom constraint to the bottom of the last card
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: aboutCardContainer.bottomAnchor, constant: 40)
        ])
    }
    
    private func setupProfileHeader() {
        profileHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileHeaderContainer)
        
        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.systemGray5
        
        // Display Name Label
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        displayNameLabel.textColor = .label
        displayNameLabel.textAlignment = .center
        
        // Email Label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        
        // Edit Profile Button
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.setTitleColor(.systemBlue, for: .normal)
        editProfileButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        editProfileButton.layer.cornerRadius = 15
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        // Add elements to profile header
        profileHeaderContainer.addSubview(profileImageView)
        profileHeaderContainer.addSubview(displayNameLabel)
        profileHeaderContainer.addSubview(emailLabel)
        profileHeaderContainer.addSubview(editProfileButton)
        
        NSLayoutConstraint.activate([
            profileHeaderContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileHeaderContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileHeaderContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            profileImageView.topAnchor.constraint(equalTo: profileHeaderContainer.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: profileHeaderContainer.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            displayNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            displayNameLabel.centerXAnchor.constraint(equalTo: profileHeaderContainer.centerXAnchor),
            displayNameLabel.leadingAnchor.constraint(equalTo: profileHeaderContainer.leadingAnchor, constant: 20),
            displayNameLabel.trailingAnchor.constraint(equalTo: profileHeaderContainer.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: profileHeaderContainer.centerXAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: profileHeaderContainer.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: profileHeaderContainer.trailingAnchor, constant: -20),
            
            editProfileButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            editProfileButton.centerXAnchor.constraint(equalTo: profileHeaderContainer.centerXAnchor),
            editProfileButton.widthAnchor.constraint(equalToConstant: 150),
            editProfileButton.heightAnchor.constraint(equalToConstant: 36),
            editProfileButton.bottomAnchor.constraint(equalTo: profileHeaderContainer.bottomAnchor, constant: -10)
        ])
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupStatsCard() {
        statsCardContainer.translatesAutoresizingMaskIntoConstraints = false
        statsCardContainer.layer.cornerRadius = 24
        statsCardContainer.layer.masksToBounds = true
        
        statsCardBlurView.translatesAutoresizingMaskIntoConstraints = false
        statsCardBlurView.layer.cornerRadius = 24
        statsCardBlurView.clipsToBounds = true
        statsCardContainer.addSubview(statsCardBlurView)
        
        contentView.addSubview(statsCardContainer)
        
        // Title Label
        let titleLabel = createCardTitleLabel(withText: "Stats")
        statsCardContainer.addSubview(titleLabel)
        
        // Stats Items: Habits, Completion, Streak
        let habitsStatView = createStatView(iconName: "checkmark.circle", title: "Habits", value: "\(habitsCount)")
        let completionStatView = createStatView(iconName: "chart.pie.fill", title: "Completion", value: "\(Int(completionRate * 100))%")
        let streakStatView = createStatView(iconName: "flame.fill", title: "Streak", value: "\(currentStreak)")
        
        // Add the stats views in a horizontal stack
        let statsStackView = UIStackView(arrangedSubviews: [habitsStatView, completionStatView, streakStatView])
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 10
        statsCardContainer.addSubview(statsStackView)
        
        NSLayoutConstraint.activate([
            statsCardContainer.topAnchor.constraint(equalTo: profileHeaderContainer.bottomAnchor, constant: 20),
            statsCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statsCardBlurView.topAnchor.constraint(equalTo: statsCardContainer.topAnchor),
            statsCardBlurView.leadingAnchor.constraint(equalTo: statsCardContainer.leadingAnchor),
            statsCardBlurView.trailingAnchor.constraint(equalTo: statsCardContainer.trailingAnchor),
            statsCardBlurView.bottomAnchor.constraint(equalTo: statsCardContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: statsCardContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: statsCardContainer.leadingAnchor, constant: 20),
            
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsCardContainer.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: statsCardContainer.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: statsCardContainer.bottomAnchor, constant: -20)
        ])
    }
    

    private func setupFriendsCard() {
        friendsCardContainer.translatesAutoresizingMaskIntoConstraints = false
        friendsCardContainer.layer.cornerRadius = 24
        friendsCardContainer.layer.masksToBounds = true
        
        friendsCardBlurView.translatesAutoresizingMaskIntoConstraints = false
        friendsCardBlurView.layer.cornerRadius = 24
        friendsCardBlurView.clipsToBounds = true
        friendsCardContainer.addSubview(friendsCardBlurView)
        
        contentView.addSubview(friendsCardContainer)
        
        // Title Label
        let titleLabel = createCardTitleLabel(withText: "Friends & Groups")
        friendsCardContainer.addSubview(titleLabel)
        
        // Friends count view
        let friendsIconContainer = UIView()
        friendsIconContainer.translatesAutoresizingMaskIntoConstraints = false
        friendsIconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        friendsIconContainer.layer.cornerRadius = 25
        friendsCardContainer.addSubview(friendsIconContainer)
        
        let friendsIcon = UIImageView(image: UIImage(systemName: "person.2.fill"))
        friendsIcon.translatesAutoresizingMaskIntoConstraints = false
        friendsIcon.contentMode = .scaleAspectFit
        friendsIcon.tintColor = .systemBlue
        friendsIconContainer.addSubview(friendsIcon)
        
        let friendsCountLabel = UILabel()
        friendsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsCountLabel.text = "\(friendsCount)"
        friendsCountLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        friendsCountLabel.textColor = .label
        friendsCountLabel.textAlignment = .center
        friendsCardContainer.addSubview(friendsCountLabel)
        
        let friendsLabel = UILabel()
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsLabel.text = "Friends"
        friendsLabel.font = UIFont.systemFont(ofSize: 16)
        friendsLabel.textColor = .secondaryLabel
        friendsLabel.textAlignment = .center
        friendsCardContainer.addSubview(friendsLabel)
        
        // Groups count view
        let groupsIconContainer = UIView()
        groupsIconContainer.translatesAutoresizingMaskIntoConstraints = false
        groupsIconContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        groupsIconContainer.layer.cornerRadius = 25
        friendsCardContainer.addSubview(groupsIconContainer)
        
        let groupsIcon = UIImageView(image: UIImage(systemName: "person.3.fill"))
        groupsIcon.translatesAutoresizingMaskIntoConstraints = false
        groupsIcon.contentMode = .scaleAspectFit
        groupsIcon.tintColor = .systemGreen
        groupsIconContainer.addSubview(groupsIcon)
        
        let groupsCountLabel = UILabel()
        groupsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        groupsCountLabel.text = "\(groupsCount)"
        groupsCountLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        groupsCountLabel.textColor = .label
        groupsCountLabel.textAlignment = .center
        friendsCardContainer.addSubview(groupsCountLabel)
        
        let groupsLabel = UILabel()
        groupsLabel.translatesAutoresizingMaskIntoConstraints = false
        groupsLabel.text = "Groups"
        groupsLabel.font = UIFont.systemFont(ofSize: 16)
        groupsLabel.textColor = .secondaryLabel
        groupsLabel.textAlignment = .center
        friendsCardContainer.addSubview(groupsLabel)
        
        // View Friends Button
        let viewFriendsButton = UIButton(type: .system)
        viewFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        viewFriendsButton.setTitle("View Friends", for: .normal)
        viewFriendsButton.setTitleColor(.systemBlue, for: .normal)
        viewFriendsButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        viewFriendsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        viewFriendsButton.layer.cornerRadius = 22
        viewFriendsButton.addTarget(self, action: #selector(viewFriendsTapped), for: .touchUpInside)
        friendsCardContainer.addSubview(viewFriendsButton)
        
        // Set up constraints to match the screenshot layout
        NSLayoutConstraint.activate([
            friendsCardContainer.topAnchor.constraint(equalTo: statsCardContainer.bottomAnchor, constant: 20),
            friendsCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            friendsCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            friendsCardBlurView.topAnchor.constraint(equalTo: friendsCardContainer.topAnchor),
            friendsCardBlurView.leadingAnchor.constraint(equalTo: friendsCardContainer.leadingAnchor),
            friendsCardBlurView.trailingAnchor.constraint(equalTo: friendsCardContainer.trailingAnchor),
            friendsCardBlurView.bottomAnchor.constraint(equalTo: friendsCardContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: friendsCardContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: friendsCardContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: friendsCardContainer.trailingAnchor, constant: -20),
            
            // Friends section
            friendsIconContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            friendsIconContainer.leadingAnchor.constraint(equalTo: friendsCardContainer.leadingAnchor, constant: 72),
            friendsIconContainer.widthAnchor.constraint(equalToConstant: 50),
            friendsIconContainer.heightAnchor.constraint(equalToConstant: 50),
            
            friendsIcon.centerXAnchor.constraint(equalTo: friendsIconContainer.centerXAnchor),
            friendsIcon.centerYAnchor.constraint(equalTo: friendsIconContainer.centerYAnchor),
            friendsIcon.widthAnchor.constraint(equalToConstant: 24),
            friendsIcon.heightAnchor.constraint(equalToConstant: 24),
            
            friendsCountLabel.topAnchor.constraint(equalTo: friendsIconContainer.bottomAnchor, constant: 8),
            friendsCountLabel.centerXAnchor.constraint(equalTo: friendsIconContainer.centerXAnchor),
            
            friendsLabel.topAnchor.constraint(equalTo: friendsCountLabel.bottomAnchor, constant: 2),
            friendsLabel.centerXAnchor.constraint(equalTo: friendsIconContainer.centerXAnchor),
            
            // Groups section
            groupsIconContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            groupsIconContainer.trailingAnchor.constraint(equalTo: friendsCardContainer.trailingAnchor, constant: -72),
            groupsIconContainer.widthAnchor.constraint(equalToConstant: 50),
            groupsIconContainer.heightAnchor.constraint(equalToConstant: 50),
            
            groupsIcon.centerXAnchor.constraint(equalTo: groupsIconContainer.centerXAnchor),
            groupsIcon.centerYAnchor.constraint(equalTo: groupsIconContainer.centerYAnchor),
            groupsIcon.widthAnchor.constraint(equalToConstant: 24),
            groupsIcon.heightAnchor.constraint(equalToConstant: 24),
            
            groupsCountLabel.topAnchor.constraint(equalTo: groupsIconContainer.bottomAnchor, constant: 8),
            groupsCountLabel.centerXAnchor.constraint(equalTo: groupsIconContainer.centerXAnchor),
            
            groupsLabel.topAnchor.constraint(equalTo: groupsCountLabel.bottomAnchor, constant: 2),
            groupsLabel.centerXAnchor.constraint(equalTo: groupsIconContainer.centerXAnchor),
            
            // View Friends button
            viewFriendsButton.topAnchor.constraint(equalTo: friendsLabel.bottomAnchor, constant: 24),
            viewFriendsButton.leadingAnchor.constraint(equalTo: friendsCardContainer.leadingAnchor, constant: 20),
            viewFriendsButton.trailingAnchor.constraint(equalTo: friendsCardContainer.trailingAnchor, constant: -20),
            viewFriendsButton.heightAnchor.constraint(equalToConstant: 44),
            viewFriendsButton.bottomAnchor.constraint(equalTo: friendsCardContainer.bottomAnchor, constant: -16)
        ])
        
        // Save references to these labels so we can update them when data changes
        self.friendsCountLabel = friendsCountLabel
        self.groupsCountLabel = groupsCountLabel
    }
    
    private func setupAchievementsCard() {
        achievementsCardContainer.translatesAutoresizingMaskIntoConstraints = false
        achievementsCardContainer.layer.cornerRadius = 24
        achievementsCardContainer.layer.masksToBounds = true
        
        achievementsCardBlurView.translatesAutoresizingMaskIntoConstraints = false
        achievementsCardBlurView.layer.cornerRadius = 24
        achievementsCardBlurView.clipsToBounds = true
        achievementsCardContainer.addSubview(achievementsCardBlurView)
        
        contentView.addSubview(achievementsCardContainer)
        
        // Title Label
        let titleLabel = createCardTitleLabel(withText: "Achievements")
        achievementsCardContainer.addSubview(titleLabel)
        
        // Achievement Items
        let earlyBirdView = createAchievementView(
            iconName: "sunrise.fill",
            title: "Early Bird",
            description: "Complete a morning habit 5 days in a row",
            progress: 0.6,
            iconColor: .systemOrange
        )
        
        let consistentView = createAchievementView(
            iconName: "calendar.badge.clock",
            title: "Consistency King",
            description: "Complete all habits for 7 days straight",
            progress: 0.8,
            iconColor: .systemPurple
        )
        
        let perfectWeekView = createAchievementView(
            iconName: "star.fill",
            title: "Perfect Week",
            description: "100% completion rate for a week",
            progress: 0.4,
            iconColor: .systemYellow
        )
        
        // Achievement Stack
        let achievementStackView = UIStackView(arrangedSubviews: [earlyBirdView, consistentView, perfectWeekView])
        achievementStackView.translatesAutoresizingMaskIntoConstraints = false
        achievementStackView.axis = .vertical
        achievementStackView.spacing = 16
        achievementStackView.distribution = .fillEqually
        achievementsCardContainer.addSubview(achievementStackView)
        
        NSLayoutConstraint.activate([
            achievementsCardContainer.topAnchor.constraint(equalTo: friendsCardContainer.bottomAnchor, constant: 20),
            achievementsCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementsCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            achievementsCardBlurView.topAnchor.constraint(equalTo: achievementsCardContainer.topAnchor),
            achievementsCardBlurView.leadingAnchor.constraint(equalTo: achievementsCardContainer.leadingAnchor),
            achievementsCardBlurView.trailingAnchor.constraint(equalTo: achievementsCardContainer.trailingAnchor),
            achievementsCardBlurView.bottomAnchor.constraint(equalTo: achievementsCardContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: achievementsCardContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: achievementsCardContainer.leadingAnchor, constant: 20),
            
            achievementStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            achievementStackView.leadingAnchor.constraint(equalTo: achievementsCardContainer.leadingAnchor, constant: 20),
            achievementStackView.trailingAnchor.constraint(equalTo: achievementsCardContainer.trailingAnchor, constant: -20),
            achievementStackView.bottomAnchor.constraint(equalTo: achievementsCardContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupSettingsCard() {
        settingsCardContainer.translatesAutoresizingMaskIntoConstraints = false
        settingsCardContainer.layer.cornerRadius = 24
        settingsCardContainer.layer.masksToBounds = true
        
        settingsCardBlurView.translatesAutoresizingMaskIntoConstraints = false
        settingsCardBlurView.layer.cornerRadius = 24
        settingsCardBlurView.clipsToBounds = true
        settingsCardContainer.addSubview(settingsCardBlurView)
        
        contentView.addSubview(settingsCardContainer)
        
        // Title Label
        let titleLabel = createCardTitleLabel(withText: "Settings")
        settingsCardContainer.addSubview(titleLabel)
        
        // Settings Options
        let notificationsButton = createSettingsButton(title: "Notifications", iconName: "bell.fill", action: #selector(notificationsTapped))
        let privacyButton = createSettingsButton(title: "Privacy", iconName: "lock.fill", action: #selector(privacyTapped))
        let appearanceButton = createSettingsButton(title: "Appearance", iconName: "paintbrush.fill", action: #selector(appearanceTapped))
        
        // Stack for settings buttons
        let settingsStackView = UIStackView(arrangedSubviews: [notificationsButton, privacyButton, appearanceButton])
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.axis = .vertical
        settingsStackView.spacing = 12
        settingsStackView.distribution = .fillEqually
        settingsCardContainer.addSubview(settingsStackView)
        
        NSLayoutConstraint.activate([
            settingsCardContainer.topAnchor.constraint(equalTo: achievementsCardContainer.bottomAnchor, constant: 20),
            settingsCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            settingsCardBlurView.topAnchor.constraint(equalTo: settingsCardContainer.topAnchor),
            settingsCardBlurView.leadingAnchor.constraint(equalTo: settingsCardContainer.leadingAnchor),
            settingsCardBlurView.trailingAnchor.constraint(equalTo: settingsCardContainer.trailingAnchor),
            settingsCardBlurView.bottomAnchor.constraint(equalTo: settingsCardContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: settingsCardContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: settingsCardContainer.leadingAnchor, constant: 20),
            
            settingsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            settingsStackView.leadingAnchor.constraint(equalTo: settingsCardContainer.leadingAnchor, constant: 20),
            settingsStackView.trailingAnchor.constraint(equalTo: settingsCardContainer.trailingAnchor, constant: -20),
            settingsStackView.bottomAnchor.constraint(equalTo: settingsCardContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupAboutCard() {
        aboutCardContainer.translatesAutoresizingMaskIntoConstraints = false
        aboutCardContainer.layer.cornerRadius = 24
        aboutCardContainer.layer.masksToBounds = true
        
        aboutCardBlurView.translatesAutoresizingMaskIntoConstraints = false
        aboutCardBlurView.layer.cornerRadius = 24
        aboutCardBlurView.clipsToBounds = true
        aboutCardContainer.addSubview(aboutCardBlurView)
        
        contentView.addSubview(aboutCardContainer)
        
        // Title Label
        let titleLabel = createCardTitleLabel(withText: "About")
        aboutCardContainer.addSubview(titleLabel)
        
        // About content
        let aboutLabel = UILabel()
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.text = "HabitCrew helps you build better habits and connect with friends for accountability and support."
        aboutLabel.textColor = .secondaryLabel
        aboutLabel.font = UIFont.systemFont(ofSize: 16)
        aboutLabel.numberOfLines = 0
        aboutCardContainer.addSubview(aboutLabel)
        
        // Version info
        let versionLabel = UILabel()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = "Version 1.0"
        versionLabel.textColor = .tertiaryLabel
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        aboutCardContainer.addSubview(versionLabel)
        
        // Logout Button
        let logoutButton = UIButton(type: .system)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logoutButton.layer.cornerRadius = 22
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        aboutCardContainer.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            aboutCardContainer.topAnchor.constraint(equalTo: settingsCardContainer.bottomAnchor, constant: 20),
            aboutCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            aboutCardBlurView.topAnchor.constraint(equalTo: aboutCardContainer.topAnchor),
            aboutCardBlurView.leadingAnchor.constraint(equalTo: aboutCardContainer.leadingAnchor),
            aboutCardBlurView.trailingAnchor.constraint(equalTo: aboutCardContainer.trailingAnchor),
            aboutCardBlurView.bottomAnchor.constraint(equalTo: aboutCardContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: aboutCardContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: aboutCardContainer.leadingAnchor, constant: 20),
            
            aboutLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            aboutLabel.leadingAnchor.constraint(equalTo: aboutCardContainer.leadingAnchor, constant: 20),
            aboutLabel.trailingAnchor.constraint(equalTo: aboutCardContainer.trailingAnchor, constant: -20),
            
            versionLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 12),
            versionLabel.leadingAnchor.constraint(equalTo: aboutCardContainer.leadingAnchor, constant: 20),
            
            logoutButton.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 16),
            logoutButton.centerXAnchor.constraint(equalTo: aboutCardContainer.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.bottomAnchor.constraint(equalTo: aboutCardContainer.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Helper Methods for UI Components
    
    private func createCardTitleLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }
    
    private func createStatView(iconName: String, title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        
        // Value Label
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        container.addSubview(iconView)
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: container.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createDetailStatView(iconName: String, title: String, value: String, iconColor: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon container with colored background
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 20
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = iconColor
        
        // Value Label
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .label
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        
        // Content Stack
        let contentStack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 4
        
        // Add to container
        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            contentStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createActionButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func createSettingsButton(title: String, iconName: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 12
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        // Chevron
        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.tintColor = .tertiaryLabel
        chevronView.contentMode = .scaleAspectFit
        
        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(chevronView)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 50),
            
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            chevronView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 14),
            chevronView.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return container
    }
    
    private func createAchievementView(iconName: String, title: String, description: String, progress: Float, iconColor: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 12
        
        // Icon with colored background
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 16
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        
        // Title and description
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        
        // Progress bar
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = progress
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = iconColor
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        
        // Progress percentage
        let percentLabel = UILabel()
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.text = "\(Int(progress * 100))%"
        percentLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        percentLabel.textColor = .secondaryLabel
        
        // Add subviews
        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        container.addSubview(progressView)
        container.addSubview(percentLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            progressView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -50),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            progressView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            percentLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            percentLabel.leadingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: 8),
            percentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    // MARK: - Data Fetching Methods
    
    private func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            
            // Create user profile
            self.userProfile = UserProfile(from: data)
            
            // Update UI with profile data
            DispatchQueue.main.async {
                self.updateProfileUI()
            }
        }
    }
    
    private func fetchUserStats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Get friends count
        db.collection("users").document(uid).collection("friends")
            .getDocuments { [weak self] snapshot, _ in
                self?.friendsCount = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.updateStatsUI()
                }
            }
        
        // Get groups count
        db.collection("users").document(uid).collection("groups")
            .getDocuments { [weak self] snapshot, _ in
                self?.groupsCount = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.updateStatsUI()
                }
            }
        
        // Get habits stats
        db.collection("users").document(uid).collection("habits")
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self else { return }
                
                let habits = snapshot?.documents.compactMap { doc -> [String: Any]? in
                    return doc.data()
                } ?? []
                
                self.habitsCount = habits.count
                
                // Calculate completion rate
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                var totalScheduled = 0
                var totalCompleted = 0
                
                for habitData in habits {
                    guard let days = habitData["days"] as? [Int] else { continue }
                    let doneDatesDict = habitData["doneDates"] as? [String: Any] ?? [:]
                    
                    let weekday = (calendar.component(.weekday, from: today) + 6) % 7
                    for i in 0..<7 {
                        let date = calendar.date(byAdding: .day, value: -i, to: today)!
                        let dayOfWeek = (calendar.component(.weekday, from: date) + 6) % 7
                        
                        if days.contains(dayOfWeek) {
                            totalScheduled += 1
                            
                            let dateString = self.dateFormatter.string(from: date)
                            let isDone = doneDatesDict[dateString] as? Bool ?? false
                            
                            if isDone {
                                totalCompleted += 1
                            }
                        }
                    }
                }
                
                self.completionRate = totalScheduled > 0 ? Float(totalCompleted) / Float(totalScheduled) : 0
                
                // Calculate current streak
                var currentStreak = 0
                for i in 0..<30 {
                    let date = calendar.date(byAdding: .day, value: -i, to: today)!
                    let dateString = self.dateFormatter.string(from: date)
                    let dayOfWeek = (calendar.component(.weekday, from: date) + 6) % 7
                    
                    let scheduledHabitsForDay = habits.filter { habit in
                        guard let days = habit["days"] as? [Int] else { return false }
                        return days.contains(dayOfWeek)
                    }
                    
                    if scheduledHabitsForDay.isEmpty {
                        // No habits scheduled for this day, continue streak
                        continue
                    }
                    
                    let completedAll = scheduledHabitsForDay.allSatisfy { habit in
                        let doneDatesDict = habit["doneDates"] as? [String: Any] ?? [:]
                        return doneDatesDict[dateString] as? Bool ?? false
                    }
                    
                    if completedAll {
                        currentStreak += 1
                    } else if i > 0 { // Allow today to be incomplete
                        break
                    }
                }
                
                self.currentStreak = currentStreak
                
                DispatchQueue.main.async {
                    self.updateStatsUI()
                }
            }
    }
    
    private func updateProfileUI() {
        guard let profile = userProfile else { return }
        
        // Update display name and email
        displayNameLabel.text = profile.displayName
        emailLabel.text = Auth.auth().currentUser?.email
        
        // Load profile image if available
        if let photoUrl = Auth.auth().currentUser?.photoURL {
            URLSession.shared.dataTask(with: photoUrl) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                } else {
                    // Show initials if no image
                    DispatchQueue.main.async {
                        self?.setProfileInitials()
                    }
                }
            }.resume()
        } else {
            setProfileInitials()
        }
    }
    
    private func updateStatsUI() {
        // Find the stats views and update them with the fetched data
        for subview in statsCardContainer.subviews {
            if let stackView = subview as? UIStackView {
                for (index, view) in stackView.arrangedSubviews.enumerated() {
                    for subview in view.subviews {
                        if let label = subview as? UILabel, label.font == UIFont.systemFont(ofSize: 28, weight: .bold) {
                            switch index {
                            case 0: label.text = "\(habitsCount)"
                            case 1: label.text = "\(Int(completionRate * 100))%"
                            case 2: label.text = "\(currentStreak)"
                            default: break
                            }
                        }
                    }
                }
            }
        }
        
        // Update friends card stats
        for subview in friendsCardContainer.subviews {
            if let stackView = subview as? UIStackView {
                for (index, view) in stackView.arrangedSubviews.enumerated() {
                    for subview in view.subviews {
                        if let stackView = subview as? UIStackView {
                            for sv in stackView.arrangedSubviews {
                                if let label = sv as? UILabel, label.font == UIFont.systemFont(ofSize: 24, weight: .bold) {
                                    switch index {
                                    case 0: label.text = "\(friendsCount)"
                                    case 1: label.text = "\(groupsCount)"
                                    default: break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setProfileInitials() {
        if let name = userProfile?.displayName, !name.isEmpty {
            let initial = String(name.prefix(1)).uppercased()
            
            // Create image with initials
            let size = CGSize(width: 100, height: 100)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.systemBlue.withAlphaComponent(0.2).cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.systemBlue
            ]
            
            let text = initial
            let textSize = text.size(withAttributes: attributes)
            let point = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
            text.draw(at: point, withAttributes: attributes)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            profileImageView.image = image
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func profileImageTapped() {
        let actionSheet = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            uploadProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadProfileImage(originalImage)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Uploading", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        // Upload to Firebase Storage
        let storageRef = storage.reference().child("profileImages/\(uid).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("Error uploading image: \(error?.localizedDescription ?? "unknown error")")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self?.showAlert(title: "Error", message: "Failed to upload image.")
                    }
                }
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { [weak self] url, error in
                guard let downloadURL = url, error == nil else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true) {
                            self?.showAlert(title: "Error", message: "Failed to process image.")
                        }
                    }
                    return
                }
                
                // Update user profile with new photo URL
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = downloadURL
                changeRequest?.commitChanges { error in
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true) {
                            if let error = error {
                                self?.showAlert(title: "Error", message: "Failed to update profile: \(error.localizedDescription)")
                            } else {
                                // Update the UI with the new image
                                self?.profileImageView.image = image
                                
                                // Update Firestore
                                if let uid = Auth.auth().currentUser?.uid {
                                    self?.db.collection("users").document(uid).updateData([
                                        "photoURL": downloadURL.absoluteString
                                    ])
                                }
                            }
                        }
                    }
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100
            DispatchQueue.main.async {
                loadingAlert.message = "Uploading: \(Int(percentComplete))%"
            }
        }
    }
    
    @objc private func editProfileTapped() {
        let alert = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Display Name"
            textField.text = self.userProfile?.displayName
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak alert] _ in
            guard let self = self,
                  let name = alert?.textFields?.first?.text,
                  !name.isEmpty,
                  let uid = Auth.auth().currentUser?.uid else { return }
            
            // Update Firebase Auth display name
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges { error in
                if let error = error {
                    print("Error updating display name: \(error.localizedDescription)")
                    return
                }
                
                // Update Firestore
                self.db.collection("users").document(uid).updateData([
                    "displayName": name
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update local profile and UI
                    if var updatedProfile = self.userProfile {
                        // Create a new UserProfile with updated display name
                        let newProfile = UserProfile(
                            uid: updatedProfile.uid,
                            displayName: name,
                            isOnline: updatedProfile.isOnline,
                            lastSeen: updatedProfile.lastSeen
                        )
                        self.userProfile = newProfile
                        
                        DispatchQueue.main.async {
                            self.displayNameLabel.text = name
                            
                            // If using initials, update them
                            if self.profileImageView.image == nil {
                                self.setProfileInitials()
                            }
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func viewFriendsTapped() {
        let friendsVC = FriendsViewController()
        navigationController?.pushViewController(friendsVC, animated: true)
    }
    
    @objc private func notificationsTapped() {
        // For now, show a placeholder alert
        showAlert(title: "Notifications", message: "Notification settings would be displayed here.")
    }
    
    @objc private func privacyTapped() {
        // For now, show a placeholder alert
        showAlert(title: "Privacy", message: "Privacy settings would be displayed here.")
    }
    
    @objc private func appearanceTapped() {
        // For now, show a placeholder alert
        showAlert(title: "Appearance", message: "Appearance settings would be displayed here.")
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            do {
                try Auth.auth().signOut()
                self?.navigationController?.popViewController(animated: true)
                self?.dismiss(animated: true)
            } catch {
                self?.showAlert(title: "Error", message: "Failed to log out: \(error.localizedDescription)")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
