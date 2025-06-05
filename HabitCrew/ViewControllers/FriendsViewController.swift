//
//  FriendsViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit
import FirebaseFirestore

class FriendsViewController: UIViewController {
    
    // UI Components
    private let segmentedControl = UISegmentedControl(items: ["Friends", "Requests"])
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // Data
    private var friends: [User] = []
    private var pendingRequests: [User] = []
    private var filteredItems: [User] = []
    private var isLoading = true
    
    // Message listeners
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove message listeners when the view disappears
        for (_, listener) in messageListeners {
            listener.remove()
        }
        messageListeners.removeAll()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Segmented Control
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        // Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search friends..."
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        // Empty State Label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No friends yet. Add someone to get started!"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add friend button in navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addFriendTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.register(RequestCell.self, forCellReuseIdentifier: "RequestCell")
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func loadData() {
        isLoading = true
        activityIndicator.startAnimating()
        tableView.reloadData()
        
        // Load friends list
        FriendsService.shared.getFriends { [weak self] result in
            switch result {
            case .success(let friends):
                self?.friends = friends
                
                // Setup message listeners for each friend
                for friend in friends {
                    self?.setupMessageListener(for: friend.id)
                }
                
                // Load pending requests after friends
                self?.loadPendingRequests()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.activityIndicator.stopAnimating()
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func loadPendingRequests() {
        FriendsService.shared.getPendingFriendRequests { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let requests):
                    self?.pendingRequests = requests
                    self?.updateUI()
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func setupMessageListener(for userId: String) {
        // Remove existing listener if any
        messageListeners[userId]?.remove()
        
        // Setup new listener
        let listener = MessageService.shared.setupMessagesListener(with: userId) { [weak self] result in
            switch result {
            case .success(let message):
                // Update UI if the view is currently showing friends
                if self?.segmentedControl.selectedSegmentIndex == 0 {
                    if let index = self?.friends.firstIndex(where: { $0.id == message.senderId }) {
                        DispatchQueue.main.async {
                            self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    }
                }
                
                // Show notification for new message
                self?.showMessageNotification(message: message)
                
            case .failure(let error):
                print("Message listener error: \(error.localizedDescription)")
            }
        }
        
        messageListeners[userId] = listener
    }
    
    private func showMessageNotification(message: Message) {
        // Find the sender's name
        if let sender = friends.first(where: { $0.id == message.senderId }) {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            let bannerView = MessageBannerView(senderName: sender.username, messagePreview: message.content)
            view.addSubview(bannerView)
            
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
                bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                bannerView.heightAnchor.constraint(equalToConstant: 70)
            ])
            
            bannerView.show { [weak self] in
                // Handle tap on banner - go to message view
                self?.openChatWith(user: sender)
            }
        }
    }
    
    private func updateUI() {
        // Update filtered items based on current segment
        if segmentedControl.selectedSegmentIndex == 0 {
            filteredItems = friends
            emptyStateLabel.text = "No friends yet. Add someone to get started!"
        } else {
            filteredItems = pendingRequests
            emptyStateLabel.text = "No pending friend requests."
        }
        
        // Apply search filter if there's text in the search bar
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredItems = filteredItems.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
        
        emptyStateLabel.isHidden = !filteredItems.isEmpty
        tableView.reloadData()
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func segmentedControlValueChanged() {
        updateUI()
    }
    
    @objc private func addFriendTapped() {
        let addFriendVC = AddFriendViewController()
        addFriendVC.delegate = self
        let navController = UINavigationController(rootViewController: addFriendVC)
        present(navController, animated: true)
    }
    
    private func openChatWith(user: User) {
        let chatVC = ChatViewController(friend: user)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 3
        }
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Loading..."
            return cell
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as? FriendCell else {
                return UITableViewCell()
            }
            
            let friend = filteredItems[indexPath.row]
            cell.configure(with: friend)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as? RequestCell else {
                return UITableViewCell()
            }
            
            let request = filteredItems[indexPath.row]
            cell.configure(with: request)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let friend = filteredItems[indexPath.row]
            openChatWith(user: friend)
        }
    }
}

// MARK: - UISearchBarDelegate
extension FriendsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - RequestCellDelegate
extension FriendsViewController: RequestCellDelegate {
    
    func didTapAcceptButton(for user: User) {
        FriendsService.shared.acceptFriendRequest(from: user.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Reload data to update both friends and requests lists
                    self?.loadData()
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func didTapDeclineButton(for user: User) {
        FriendsService.shared.declineFriendRequest(from: user.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Remove the request from the list and update UI
                    if let index = self?.pendingRequests.firstIndex(where: { $0.id == user.id }) {
                        self?.pendingRequests.remove(at: index)
                        self?.updateUI()
                    }
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - AddFriendViewControllerDelegate
extension FriendsViewController: AddFriendViewControllerDelegate {
    func didSendFriendRequest() {
        // No need to reload data, as the sent request doesn't appear in our lists
        let alert = UIAlertController(title: "Request Sent", message: "Friend request sent successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}