import UIKit
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    // UI Components
    private let tableView = UITableView()
    private let messageInputView = MessageInputView()
    private var messageInputBottomConstraint: NSLayoutConstraint!
    
    // Data
    private let friend: User
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    init(friend: User) {
        self.friend = friend
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupMessageInput()
        setupKeyboardObservers()
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMessageListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageListener?.remove()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = friend.username
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        view.addSubview(tableView)
        
        // Message Input View
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.delegate = self
        view.addSubview(messageInputView)
        
        // Layout Constraints
        messageInputBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBottomConstraint
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.register(DateSeparatorCell.self, forCellReuseIdentifier: "DateSeparatorCell")
    }
    
    private func setupMessageInput() {
        messageInputView.configure()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func loadMessages() {
        MessageService.shared.getMessages(with: friend.id) { [weak self] result in
            switch result {
            case .success(let messages):
                DispatchQueue.main.async {
                    self?.messages = messages
                    self?.tableView.reloadData()
                    self?.scrollToBottom(animated: false)
                }
                
            case .failure(let error):
                print("Error loading messages: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupMessageListener() {
        messageListener = MessageService.shared.setupMessagesListener(with: friend.id) { [weak self] result in
            switch result {
            case .success(let message):
                DispatchQueue.main.async {
                    // Check if message already exists - fixed optional unwrapping logic
                    if let strongSelf = self {
                        let messageExists = strongSelf.messages.contains { $0.id == message.id }
                        if !messageExists {
                            strongSelf.messages.append(message)
                            strongSelf.messages.sort { $0.timestamp < $1.timestamp }
                            strongSelf.tableView.reloadData()
                            strongSelf.scrollToBottom(animated: true)
                        }
                    }
                }
                
            case .failure(let error):
                print("Message listener error: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        MessageService.shared.sendMessage(to: friend.id, type: .text, content: text) { [weak self] result in
            switch result {
            case .success(let message):
                DispatchQueue.main.async {
                    self?.messages.append(message)
                    self?.messages.sort { $0.timestamp < $1.timestamp }
                    self?.tableView.reloadData()
                    self?.scrollToBottom(animated: true)
                    self?.messageInputView.clearText()
                }
                
            case .failure(let error):
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if lastRow >= 0 {
            tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: animated)
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        messageInputBottomConstraint.constant = -keyboardHeight + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        messageInputBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        // Check if we need to insert a date separator
        if shouldInsertDateSeparator(at: indexPath.row) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateSeparatorCell", for: indexPath) as? DateSeparatorCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: message.timestamp)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let isCurrentUser = message.senderId == AuthService.shared.getCurrentUserId()
        cell.configure(with: message, isCurrentUser: isCurrentUser)
        
        return cell
    }
    
    private func shouldInsertDateSeparator(at index: Int) -> Bool {
        guard index > 0 else { return false }
        
        let currentMessage = messages[index]
        let previousMessage = messages[index - 1]
        
        let calendar = Calendar.current
        return !calendar.isDate(currentMessage.timestamp, inSameDayAs: previousMessage.timestamp)
    }
}

// MARK: - MessageInputViewDelegate
extension ChatViewController: MessageInputViewDelegate {
    func messageInputView(_ view: MessageInputView, didSendMessage text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        sendMessage(text)
    }
}
