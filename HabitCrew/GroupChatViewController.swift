//
//  GroupChatViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 26/06/25.
//


import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

class GroupChatViewController: UIViewController {
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    private var me: UserProfile!
    private let group: Group
    private var messages: [HabitMessage] = []
    private var groupMembers: [UserProfile] = []
    
    // UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputBar = MessageInputBar()
    private let headerView = UIView()
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var fullScreenImageView: UIImageView?
    private var currentlyPlayingCell: ChatMessageCell?
    private var currentlyPlayingIndexPath: IndexPath?
    
    // MARK: - Init
    init(group: Group, me: UserProfile) {
        self.group = group
        self.me = me
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        fetchGroupMembers()
        listenForMessages()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - UI Setup
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.05, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        gradient.isGeometryFlipped = false
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupUI() {
        // Header setup
        setupHeader()
        
        // TableView setup
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.keyboardDismissMode = .interactive
        tableView.register(GroupMessageCell.self, forCellReuseIdentifier: "groupcell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Input bar setup
        inputBar.delegate = self
        inputBar.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        
        // Constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 70),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),
            
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 62)
        ])
        
        // Tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        headerView.layer.cornerRadius = 24
        headerView.clipsToBounds = true
        headerView.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.07).cgColor
        headerView.layer.shadowOpacity = 1.0
        headerView.layer.shadowRadius = 10
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.addSubview(headerView)
        
        // Back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        backButton.tintColor = .systemBlue
        backButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        backButton.layer.cornerRadius = 16
        backButton.layer.masksToBounds = true
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        // Group image
        let groupImageView = UIImageView()
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.layer.cornerRadius = 22
        groupImageView.layer.masksToBounds = true
        groupImageView.backgroundColor = UIColor.systemGray5
        groupImageView.image = UIImage(systemName: "person.3.fill")
        groupImageView.tintColor = .systemBlue
        
        // If a group image URL exists, load it
        if let imageURL = group.imageURL, let url = URL(string: imageURL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        groupImageView.image = image
                    }
                }
            }.resume()
        }
        
        headerView.addSubview(groupImageView)
        
        // Group name label
        let nameLabel = UILabel()
        nameLabel.text = group.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nameLabel)
        
        // Member count label
        let memberCountLabel = UILabel()
        memberCountLabel.text = "\(group.memberUIDs.count) members"
        memberCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        memberCountLabel.textColor = .secondaryLabel
        memberCountLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(memberCountLabel)
        
        // Info button
        let infoButton = UIButton(type: .system)
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.tintColor = .systemBlue
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        headerView.addSubview(infoButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 35),
            backButton.heightAnchor.constraint(equalToConstant: 35),
            
            groupImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            groupImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            groupImageView.widthAnchor.constraint(equalToConstant: 44),
            groupImageView.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: groupImageView.topAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -12),
            
            memberCountLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            memberCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            infoButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            infoButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 40),
            infoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func infoTapped() {
        let alert = UIAlertController(title: "Group Info", message: group.description, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "View Members", style: .default, handler: { [weak self] _ in
            self?.showGroupMembers()
        }))
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showGroupMembers() {
        let alert = UIAlertController(title: "Group Members", message: nil, preferredStyle: .actionSheet)
        
        for member in groupMembers {
            alert.addAction(UIAlertAction(title: member.displayName, style: .default, handler: nil))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Fetching
    private func fetchGroupMembers() {
        let memberIds = group.memberUIDs
        
        db.collection("users").whereField("uid", in: memberIds).getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            
            let members = documents.compactMap { doc -> UserProfile? in
                return UserProfile(from: doc.data())
            }
            
            self.groupMembers = members
        }
    }
    
    // MARK: - Firebase Messaging
    private func listenForMessages() {
        let groupId = "group_\(group.id)"
        
        listener = db.collection("groupChats").document(groupId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snap, error in
                if let error = error {
                    print("[GroupChatViewController] Firestore error:", error)
                }
                
                guard let self = self else { return }
                
                let newMessages = snap?.documents.compactMap { doc -> HabitMessage? in
                    var message = HabitMessage(from: doc.data())
                    if message == nil {
                        print("[GroupChatViewController] Failed to parse message:", doc.data())
                    }
                    return message
                } ?? []
                
                self.messages = newMessages
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom(animated: false)
                }
            }
    }
    
    func sendMessage(_ message: HabitMessage) {
        let groupId = "group_\(group.id)"
        
        db.collection("groupChats").document(groupId).collection("messages")
            .document(message.id).setData(message.dictionary)
    }
    
    func scrollToBottom(animated: Bool = true) {
        guard messages.count > 0 else { return }
        let last = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: last, at: .bottom, animated: animated)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension GroupChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupcell", for: indexPath) as! GroupMessageCell
        
        let message = messages[indexPath.row]
        let isMe = message.senderId == me.uid
        
        // Find sender information
        let sender = groupMembers.first { $0.uid == message.senderId }
        
        // Configure cell
        cell.configure(
            with: message,
            isOutgoing: isMe,
            senderName: isMe ? "You" : (sender?.displayName ?? "Unknown"),
            senderInitial: (sender?.displayName.first.map { String($0) } ?? "?").uppercased()
        )
        
        return cell
    }
}

// MARK: - MessageInputBarDelegate
extension GroupChatViewController: MessageInputBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func didSendText(_ text: String) {
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: me.uid,
            timestamp: Date(),
            type: .text,
            content: text,
            audioURL: nil,
            checkinData: nil,
            summaryData: nil,
            pollData: nil,
            reactions: nil
        )
        
        sendMessage(msg)
    }
    
    func didTapPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let img = info[.originalImage] as? UIImage else { return }
        uploadImage(img)
    }
    
    func uploadImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        let ref = storage.reference().child("groupChatImages/\(UUID().uuidString).jpg")
        
        ref.putData(data, metadata: nil) { [weak self] meta, error in
            guard let self = self, error == nil else { return }
            
            ref.downloadURL { url, _ in
                guard let url = url else { return }
                
                let msg = HabitMessage(
                    id: UUID().uuidString,
                    senderId: self.me.uid,
                    timestamp: Date(),
                    type: .image,
                    content: url.absoluteString,
                    audioURL: nil,
                    checkinData: nil,
                    summaryData: nil,
                    pollData: nil,
                    reactions: nil
                )
                
                self.sendMessage(msg)
            }
        }
    }
    
    func didStartRecording() {
        // Implementation for voice recording
    }
    
    func didStopRecording(cancelled: Bool) {
        // Implementation for voice recording
    }
    
    func didSendCheckin(_ checkin: CheckinData) {
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: me.uid,
            timestamp: Date(),
            type: .checkin,
            content: nil,
            audioURL: nil,
            checkinData: checkin,
            summaryData: nil,
            pollData: nil,
            reactions: nil
        )
        
        sendMessage(msg)
    }
    
    func didSendNudge(_ nudge: String) {
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: me.uid,
            timestamp: Date(),
            type: .nudge,
            content: nudge,
            audioURL: nil,
            checkinData: nil,
            summaryData: nil,
            pollData: nil,
            reactions: nil
        )
        
        sendMessage(msg)
    }
    
    func didSendSummary(_ summary: SummaryData) {
        let msg = HabitMessage(
            id: UUID().uuidString,
            senderId: me.uid,
            timestamp: Date(),
            type: .summary,
            content: nil,
            audioURL: nil,
            checkinData: nil,
            summaryData: summary,
            pollData: nil,
            reactions: nil
        )
        
        sendMessage(msg)
    }
}

// MARK: - Group Message Cell
class GroupMessageCell: UITableViewCell {
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let nameLabel = UILabel()
    private let senderAvatar = UIView()
    private let senderInitialLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Bubble view
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.masksToBounds = true
        contentView.addSubview(bubbleView)
        
        // Sender avatar circle
        senderAvatar.translatesAutoresizingMaskIntoConstraints = false
        senderAvatar.backgroundColor = UIColor.systemGray5
        senderAvatar.layer.cornerRadius = 15
        senderAvatar.layer.masksToBounds = true
        contentView.addSubview(senderAvatar)
        
        // Sender initial label
        senderInitialLabel.translatesAutoresizingMaskIntoConstraints = false
        senderInitialLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        senderInitialLabel.textAlignment = .center
        senderInitialLabel.textColor = .systemBlue
        senderAvatar.addSubview(senderInitialLabel)
        
        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .secondaryLabel
        bubbleView.addSubview(nameLabel)
        
        // Message label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        bubbleView.addSubview(messageLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            senderAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            senderAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            senderAvatar.widthAnchor.constraint(equalToConstant: 30),
            senderAvatar.heightAnchor.constraint(equalToConstant: 30),
            
            senderInitialLabel.centerXAnchor.constraint(equalTo: senderAvatar.centerXAnchor),
            senderInitialLabel.centerYAnchor.constraint(equalTo: senderAvatar.centerYAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: senderAvatar.trailingAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            nameLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -12),
            
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: HabitMessage, isOutgoing: Bool, senderName: String, senderInitial: String) {
        nameLabel.text = senderName
        messageLabel.text = message.content
        senderInitialLabel.text = senderInitial
        
        if isOutgoing {
            bubbleView.backgroundColor = UIColor(red: 0.75, green: 0.88, blue: 1, alpha: 1)
            nameLabel.isHidden = true
            senderAvatar.isHidden = true
            
            // Update constraints for outgoing messages (right-aligned)
            NSLayoutConstraint.deactivate(bubbleView.constraints.filter { $0.firstAttribute == .leading })
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 80).isActive = true
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        } else {
            bubbleView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
            nameLabel.isHidden = false
            senderAvatar.isHidden = false
            
            // Update constraints for incoming messages (left-aligned)
            NSLayoutConstraint.deactivate(bubbleView.constraints.filter { $0.firstAttribute == .trailing })
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10).isActive = true
        }
    }
}
