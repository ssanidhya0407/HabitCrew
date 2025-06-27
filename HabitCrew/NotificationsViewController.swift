//
//  NotificationsViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 26/06/25.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore

class NotificationsViewController: UIViewController {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var notifications: [HabitNotification] = []
    private var notificationsListener: ListenerRegistration?
    
    // Gradient background
    private let gradientLayer = CAGradientLayer()
    
    // UI Components
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        listenForNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    deinit {
        notificationsListener?.remove()
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
    
    private func setupUI() {
        // Navigation Bar Setup
        title = "Notifications"
        navigationItem.largeTitleDisplayMode = .never
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), 
                                         style: .plain, 
                                         target: self, 
                                         action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        // Clear All Button
        let clearAllButton = UIBarButtonItem(title: "Clear All", 
                                           style: .plain, 
                                           target: self, 
                                           action: #selector(clearAllTapped))
        navigationItem.rightBarButtonItem = clearAllButton
        
        // Table View Setup
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationCardCell.self, forCellReuseIdentifier: "notificationCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Empty State View
        setupEmptyStateView()
        updateEmptyStateVisibility()
    }
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 280),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Bell Icon
        let bellImageView = UIImageView(image: UIImage(systemName: "bell.slash.fill"))
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        bellImageView.contentMode = .scaleAspectFit
        bellImageView.tintColor = UIColor.systemGray3
        emptyStateView.addSubview(bellImageView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No Notifications"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        emptyStateView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "You'll see habit reminders and updates here."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        emptyStateView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            bellImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            bellImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            bellImageView.widthAnchor.constraint(equalToConstant: 60),
            bellImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: bellImageView.bottomAnchor, constant: 16),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
    }
    
    private func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !notifications.isEmpty
        tableView.isHidden = notifications.isEmpty
    }
    
    // MARK: - Data Handling
    private func listenForNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        notificationsListener?.remove()
        notificationsListener = db.collection("users").document(uid).collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting notifications: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.notifications = []
                    self.updateEmptyStateVisibility()
                    self.tableView.reloadData()
                    return
                }
                
                self.notifications = documents.compactMap { document -> HabitNotification? in
                    let data = document.data()
                    
                    guard let title = data["title"] as? String,
                          let message = data["message"] as? String,
                          let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                          let habitId = data["habitId"] as? String,
                          let habitTitle = data["habitTitle"] as? String,
                          let habitColorHex = data["habitColorHex"] as? String else {
                        return nil
                    }
                    
                    return HabitNotification(
                        id: document.documentID,
                        title: title,
                        message: message,
                        timestamp: timestamp,
                        habitId: habitId,
                        habitTitle: habitTitle,
                        habitColorHex: habitColorHex,
                        isRead: data["isRead"] as? Bool ?? false
                    )
                }
                
                self.updateEmptyStateVisibility()
                self.tableView.reloadData()
            }
    }
    
    private func markAsRead(_ notification: HabitNotification) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("notifications").document(notification.id)
            .updateData(["isRead": true])
    }
    
    private func deleteNotification(_ notification: HabitNotification) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("notifications").document(notification.id)
            .delete()
    }
    
    @objc private func clearAllTapped() {
        let alert = UIAlertController(title: "Clear All Notifications?", 
                                     message: "This action cannot be undone.", 
                                     preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.clearAllNotifications()
        })
        
        present(alert, animated: true)
    }
    
    private func clearAllNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        // Get all notifications for the user
        db.collection("users").document(uid).collection("notifications").getDocuments { [weak self] (snapshot, error) in
            guard let self = self, let documents = snapshot?.documents, !documents.isEmpty else { return }
            
            // Add delete operations to the batch
            for document in documents {
                let docRef = self.db.collection("users").document(uid).collection("notifications").document(document.documentID)
                batch.deleteDocument(docRef)
            }
            
            // Commit the batch
            batch.commit { error in
                if let error = error {
                    print("Error clearing notifications: \(error)")
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCardCell
        
        let notification = notifications[indexPath.row]
        cell.configure(with: notification)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        
        // Mark as read
        if !notification.isRead {
            markAsRead(notification)
        }
        
        // Navigate to habit detail if the habit still exists
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("habits").document(notification.habitId).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                // If the habit doesn't exist anymore, just mark as read
                return
            }
            
            if let habitData = document.data(), let habit = Habit(from: habitData) {
                let detailVC = HabitDetailViewController(habit: habit)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = notifications[indexPath.row]
        
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            self?.deleteNotification(notification)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Notification Card Cell
class NotificationCardCell: UITableViewCell {
    
    private let cardView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let habitTitleLabel = UILabel()
    private let unreadIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Card View Setup - Glassmorphic Effect
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        contentView.addSubview(cardView)
        
        // Content Stack View
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 8
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(contentStackView)
        
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // Message Label
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 2
        
        // Habit Title Label with Pill Background
        let habitTitleContainer = UIView()
        habitTitleContainer.translatesAutoresizingMaskIntoConstraints = false
        habitTitleContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        habitTitleContainer.layer.cornerRadius = 12
        habitTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        habitTitleLabel.textColor = .systemBlue
        habitTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        habitTitleContainer.addSubview(habitTitleLabel)
        
        // Time Label
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .tertiaryLabel
        timeLabel.textAlignment = .right
        
        // Unread Indicator
        unreadIndicator.translatesAutoresizingMaskIntoConstraints = false
        unreadIndicator.backgroundColor = .systemBlue
        unreadIndicator.layer.cornerRadius = 4
        cardView.contentView.addSubview(unreadIndicator)
        
        // Add labels to stack
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        
        // Bottom row stack (habit label and time)
        let bottomRowStack = UIStackView()
        bottomRowStack.axis = .horizontal
        bottomRowStack.alignment = .center
        bottomRowStack.distribution = .equalSpacing
        bottomRowStack.translatesAutoresizingMaskIntoConstraints = false
        
        bottomRowStack.addArrangedSubview(habitTitleContainer)
        bottomRowStack.addArrangedSubview(timeLabel)
        
        contentStackView.addArrangedSubview(bottomRowStack)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            contentStackView.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor, constant: -16),
            
            habitTitleLabel.topAnchor.constraint(equalTo: habitTitleContainer.topAnchor, constant: 6),
            habitTitleLabel.leadingAnchor.constraint(equalTo: habitTitleContainer.leadingAnchor, constant: 12),
            habitTitleLabel.trailingAnchor.constraint(equalTo: habitTitleContainer.trailingAnchor, constant: -12),
            habitTitleLabel.bottomAnchor.constraint(equalTo: habitTitleContainer.bottomAnchor, constant: -6),
            
            unreadIndicator.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 16),
            unreadIndicator.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -16),
            unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with notification: HabitNotification) {
        titleLabel.text = notification.title
        messageLabel.text = notification.message
        habitTitleLabel.text = notification.habitTitle
        
        // Format time as relative if within last 24 hours, otherwise show date
        if Date().timeIntervalSince(notification.timestamp) < 24 * 60 * 60 {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            timeLabel.text = formatter.localizedString(for: notification.timestamp, relativeTo: Date())
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            timeLabel.text = formatter.string(from: notification.timestamp)
        }
        
        // Set unread indicator visibility
        unreadIndicator.isHidden = notification.isRead
        
        // Set habit title color based on habit color
        if let habitColor = UIColor(hex: notification.habitColorHex) {
            habitTitleLabel.textColor = habitColor
            habitTitleLabel.superview?.backgroundColor = habitColor.withAlphaComponent(0.15)
        } else {
            habitTitleLabel.textColor = .systemBlue
            habitTitleLabel.superview?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        }
        
        // Add a subtle shadow to the card view
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOpacity = 1
        cardView.layer.masksToBounds = false
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.cardView.alpha = highlighted ? 0.8 : 1.0
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}