import UIKit
import FirebaseFirestore

protocol AddFriendViewControllerDelegate: AnyObject {
    func didSendFriendRequest()
}

class AddFriendViewController: UIViewController {
    
    // UI Components
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // Data
    private var searchResults: [User] = []
    private var isSearching = false
    private var debounceTimer: Timer?
    
    weak var delegate: AddFriendViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Add Friend"
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search by username or email"
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        // Empty State Label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "Search for users by username or email"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        view.addSubview(emptyStateLabel)
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddFriendCell.self, forCellReuseIdentifier: "AddFriendCell")
    }
    
    private func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            updateUI()
            return
        }
        
        isSearching = true
        activityIndicator.startAnimating()
        updateUI()
        
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        
        // Use where clauses for exact match or contains instead of range queries
        // This is a simplification - in a real app you might want to implement
        // a more sophisticated search mechanism or use Cloud Functions
        usersRef.whereField("username", isEqualTo: query)
            .getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error searching users: \(error)")
                    DispatchQueue.main.async {
                        self?.isSearching = false
                        self?.activityIndicator.stopAnimating()
                        self?.updateUI()
                    }
                    return
                }
                
                var users: [User] = []
                
                for document in snapshot?.documents ?? [] {
                    if let user = User.fromFirestore(data: document.data()),
                       user.id != AuthService.shared.getCurrentUserId() { // Don't show current user
                        users.append(user)
                    }
                }
                
                // Also search by email if it's a valid email format
                if query.contains("@") {
                    usersRef.whereField("email", isEqualTo: query)
                        .getDocuments { [weak self] (snapshot, error) in
                            if let error = error {
                                print("Error searching users by email: \(error)")
                                DispatchQueue.main.async {
                                    self?.isSearching = false
                                    self?.activityIndicator.stopAnimating()
                                    self?.searchResults = users
                                    self?.updateUI()
                                }
                                return
                            }
                            
                            for document in snapshot?.documents ?? [] {
                                if let user = User.fromFirestore(data: document.data()),
                                   user.id != AuthService.shared.getCurrentUserId(), // Don't show current user
                                   !users.contains(where: { $0.id == user.id }) { // Avoid duplicates
                                    users.append(user)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self?.isSearching = false
                                self?.activityIndicator.stopAnimating()
                                self?.searchResults = users
                                self?.updateUI()
                            }
                        }
                } else {
                    // Also do a partial match search using "array-contains" if you have a "searchTerms" array field
                    // Or do a "starts with" search for username
                    usersRef.whereField("username", isGreaterThanOrEqualTo: query)
                        .whereField("username", isLessThan: query + "z")
                        .getDocuments { [weak self] (snapshot, error) in
                            if let error = error {
                                print("Error doing prefix search: \(error)")
                                DispatchQueue.main.async {
                                    self?.isSearching = false
                                    self?.activityIndicator.stopAnimating()
                                    self?.searchResults = users
                                    self?.updateUI()
                                }
                                return
                            }
                            
                            for document in snapshot?.documents ?? [] {
                                if let user = User.fromFirestore(data: document.data()),
                                   user.id != AuthService.shared.getCurrentUserId(), // Don't show current user
                                   !users.contains(where: { $0.id == user.id }), // Avoid duplicates
                                   user.username != query { // Avoid duplication from exact match above
                                    users.append(user)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self?.isSearching = false
                                self?.activityIndicator.stopAnimating()
                                self?.searchResults = users
                                self?.updateUI()
                            }
                        }
                }
            }
    }
    
    private func updateUI() {
        if isSearching {
            emptyStateLabel.isHidden = true
        } else {
            emptyStateLabel.isHidden = !searchResults.isEmpty
            
            if searchResults.isEmpty && !searchBar.text!.isEmpty {
                emptyStateLabel.text = "No users found for your search"
            } else {
                emptyStateLabel.text = "Search for users by username or email"
            }
        }
        
        tableView.reloadData()
    }
    
    private func sendFriendRequest(to userId: String) {
        activityIndicator.startAnimating()
        
        FriendsService.shared.sendFriendRequest(to: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success:
                    self?.delegate?.didSendFriendRequest()
                    self?.dismiss(animated: true)
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AddFriendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as? AddFriendCell else {
            return UITableViewCell()
        }
        
        let user = searchResults[indexPath.row]
        cell.configure(with: user)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - UISearchBarDelegate
extension AddFriendViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Debounce search to avoid excessive Firestore queries
        debounceTimer?.invalidate()
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.searchUsers(query: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text {
            searchUsers(query: searchText)
        }
    }
}

// MARK: - AddFriendCellDelegate
extension AddFriendViewController: AddFriendCellDelegate {
    func didTapAddButton(for user: User) {
        sendFriendRequest(to: user.id)
    }
}
