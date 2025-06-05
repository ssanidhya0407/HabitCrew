//
//  BuddySelectionViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//

import UIKit

protocol BuddySelectorViewControllerDelegate: AnyObject {
    func didSelectBuddies(_ buddies: [User])
}

class BuddySelectorViewController: UIViewController {
    
    // UI Components
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // Data
    private var friends: [User] = []
    private var filteredFriends: [User] = []
    private var selectedFriends: [User] = []
    private var isLoading = true
    
    weak var delegate: BuddySelectorViewControllerDelegate?
    
    init(selectedBuddies: [User]) {
        self.selectedFriends = selectedBuddies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupTableView()
        loadFriends()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Select Buddies"
        
        // Navigation bar setup
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search friends"
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        // Empty State Label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No friends found"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
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
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BuddyCell.self, forCellReuseIdentifier: "BuddyCell")
    }
    
    private func loadFriends() {
        isLoading = true
        tableView.reloadData()
        
        FriendsService.shared.getFriends { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let friends):
                    self?.friends = friends
                    self?.filteredFriends = friends
                    self?.updateUI()
                    
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        emptyStateLabel.isHidden = !filteredFriends.isEmpty
        tableView.reloadData()
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func doneTapped() {
        delegate?.didSelectBuddies(selectedFriends)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension BuddySelectorViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 3 // Skeleton cells
        }
        return filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BuddyCell", for: indexPath) as? BuddyCell else {
            return UITableViewCell()
        }
        
        if isLoading {
            cell.showSkeleton()
            return cell
        }
        
        let friend = filteredFriends[indexPath.row]
        let isSelected = selectedFriends.contains(where: { $0.id == friend.id })
        cell.configure(with: friend, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = filteredFriends[indexPath.row]
        
        if let index = selectedFriends.firstIndex(where: { $0.id == friend.id }) {
            // Deselect
            selectedFriends.remove(at: index)
        } else {
            // Select
            selectedFriends.append(friend)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UISearchBarDelegate
extension BuddySelectorViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
        
        updateUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
