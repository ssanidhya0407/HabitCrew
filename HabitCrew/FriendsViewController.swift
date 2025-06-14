import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


// MARK: - Main FriendsViewController

class FriendsViewController: UIViewController {

    private let db = Firestore.firestore()
    private var userProfile: UserProfile?
    private var friends: [UserProfile] = []
    private var incomingRequests: [UserProfile] = []
    private var groups: [Group] = []
    private var friendsListener: ListenerRegistration?
    private var requestsListener: ListenerRegistration?
    private var groupsListener: ListenerRegistration?

    // UI
    private let gradientLayer = CAGradientLayer()
    private let decorativeBlob1 = UIView()
    private let decorativeBlob2 = UIView()

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "Friends"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Connect, chat, and grow your crew"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 30
        v.layer.cornerCurve = .continuous
        v.layer.masksToBounds = true
        v.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.93)
        v.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.06).cgColor
        v.layer.shadowOpacity = 1.0
        v.layer.shadowRadius = 18
        v.layer.shadowOffset = CGSize(width: 0, height: 5)
        return v
    }()
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        table.rowHeight = 78
        return table
    }()
    private let addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Friend", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    private let createGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Group", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.17)
        button.setTitleColor(.systemGreen, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.systemGreen.withAlphaComponent(0.10).cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    private var searchModal: FriendSearchModal?
    private var groupModal: GroupCreateModal?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        setupUI()
        fetchUserProfile()
        listenForFriends()
        listenForRequests()
        listenForGroups()
    }

    deinit {
        friendsListener?.remove()
        requestsListener?.remove()
        groupsListener?.remove()
    }

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

    private func setupDecorativeBlobs() {
        decorativeBlob1.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        decorativeBlob1.layer.cornerRadius = 100
        decorativeBlob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob1)
        NSLayoutConstraint.activate([
            decorativeBlob1.widthAnchor.constraint(equalToConstant: 190),
            decorativeBlob1.heightAnchor.constraint(equalToConstant: 190),
            decorativeBlob1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -48),
            decorativeBlob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -48)
        ])
        decorativeBlob2.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.07)
        decorativeBlob2.layer.cornerRadius = 100
        decorativeBlob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob2)
        NSLayoutConstraint.activate([
            decorativeBlob2.widthAnchor.constraint(equalToConstant: 190),
            decorativeBlob2.heightAnchor.constraint(equalToConstant: 190),
            decorativeBlob2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 48),
            decorativeBlob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 48)
        ])
    }

    private func setupUI() {
        view.addSubview(greetingLabel)
        view.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            greetingLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -25),
            subtitleLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
        ])
        view.addSubview(addFriendButton)
        view.addSubview(createGroupButton)
        NSLayoutConstraint.activate([
            createGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            createGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            createGroupButton.bottomAnchor.constraint(equalTo: addFriendButton.topAnchor, constant: -10),
            createGroupButton.heightAnchor.constraint(equalToConstant: 56),

            addFriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            addFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            addFriendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            addFriendButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        addFriendButton.addTarget(self, action: #selector(addFriendTapped), for: .touchUpInside)
        createGroupButton.addTarget(self, action: #selector(createGroupTapped), for: .touchUpInside)

        view.addSubview(cardView)
        cardView.addSubview(blurView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: createGroupButton.topAnchor, constant: -18)
        ])
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        cardView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 78
        tableView.register(FriendCardCell.self, forCellReuseIdentifier: "friendcard")
        tableView.register(GroupCardCell.self, forCellReuseIdentifier: "groupcard")
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Data

    private func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { [weak self] snap, _ in
            guard let data = snap?.data(), let profile = UserProfile(from: data) else { return }
            self?.userProfile = profile
        }
    }

    private func listenForFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        friendsListener?.remove()
        friendsListener = db.collection("users").document(uid).collection("friends")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                let friendUids = docs.map { $0.documentID }
                self.fetchUserProfiles(uids: friendUids) { profiles in
                    self.friends = profiles
                    self.tableView.reloadData()
                }
            }
    }

    private func listenForRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        requestsListener?.remove()
        requestsListener = db.collection("users").document(uid).collection("friendRequests")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                let fromUids = docs.map { $0.documentID }
                self.fetchUserProfiles(uids: fromUids) { profiles in
                    self.incomingRequests = profiles
                    self.tableView.reloadData()
                }
            }
    }

    private func listenForGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        groupsListener?.remove()
        groupsListener = db.collection("users").document(uid).collection("groups")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                let groupIDs = snapshot?.documents.map { $0.documentID } ?? []
                guard !groupIDs.isEmpty else { self.groups = []; self.tableView.reloadData(); return }
                self.db.collection("groups").whereField("id", in: groupIDs).getDocuments { snap, _ in
                    let groups = snap?.documents.compactMap { doc -> Group? in
                        let data = doc.data()
                        guard let id = data["id"] as? String,
                              let name = data["name"] as? String,
                              let desc = data["description"] as? String,
                              let memberUIDs = data["memberUIDs"] as? [String] else { return nil }
                        return Group(id: id, name: name, description: desc, imageURL: data["imageURL"] as? String, memberUIDs: memberUIDs)
                    } ?? []
                    self.groups = groups
                    self.tableView.reloadData()
                }
            }
    }

    private func fetchUserProfiles(uids: [String], completion: @escaping ([UserProfile]) -> Void) {
        guard !uids.isEmpty else { completion([]); return }
        db.collection("users").whereField("uid", in: uids).getDocuments { snap, _ in
            let profiles = snap?.documents.compactMap { UserProfile(from: $0.data()) } ?? []
            completion(profiles)
        }
    }

    // MARK: - Button Actions

    @objc private func addFriendTapped() {
        let modal = FriendSearchModal(currentUser: userProfile, friends: friends, incomingRequests: incomingRequests)
        modal.onSendRequest = { [weak self] toUser in
            self?.sendFriendRequest(to: toUser)
        }
        modal.onProfileTap = { [weak self] user in
            self?.showProfile(of: user)
        }
        present(modal, animated: true)
        searchModal = modal
    }

    @objc private func createGroupTapped() {
        guard let me = userProfile else { return }
        let modal = GroupCreateModal(me: me, friends: friends)
        modal.onGroupCreate = { [weak self] group in
            self?.addGroupToFirestore(group)
        }
        present(modal, animated: true)
        groupModal = modal
    }

    private func addGroupToFirestore(_ group: Group) {
        let groupDoc = db.collection("groups").document(group.id)
        groupDoc.setData(group.dictionary)
        for uid in group.memberUIDs {
            db.collection("users").document(uid).collection("groups").document(group.id).setData([
                "id": group.id,
                "joinedAt": FieldValue.serverTimestamp()
            ])
        }
    }

    private func sendFriendRequest(to user: UserProfile) {
        guard let myProfile = userProfile else { return }
        db.collection("users").document(user.uid)
            .collection("friendRequests").document(myProfile.uid)
            .setData(myProfile.dictionary)
        db.collection("users").document(myProfile.uid)
            .collection("sentFriendRequests").document(user.uid)
            .setData(user.dictionary)
    }

    private func acceptFriendRequest(from user: UserProfile) {
        guard let myProfile = userProfile else { return }
        db.collection("users").document(myProfile.uid).collection("friends").document(user.uid)
            .setData(user.dictionary)
        db.collection("users").document(user.uid).collection("friends").document(myProfile.uid)
            .setData(myProfile.dictionary)
        db.collection("users").document(myProfile.uid).collection("friendRequests").document(user.uid)
            .delete()
    }

    private func showProfile(of user: UserProfile) {
        let profileVC = FriendProfileViewController(user: user, canMessage: friends.contains(where: {$0.uid == user.uid}))
        profileVC.onMessageTap = { [weak self] in
            self?.showChat(with: user)
        }
        present(profileVC, animated: true)
    }

    private func showChat(with user: UserProfile) {
        let chatVC = ChatViewController(friend: user)
        chatVC.me = self.userProfile
        present(chatVC, animated: true)
    }
}

// MARK: - TableView DataSource/Delegate

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if !groups.isEmpty { return incomingRequests.isEmpty ? 2 : 3 }
        return incomingRequests.isEmpty ? 1 : 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !groups.isEmpty && section == 0 { return groups.count }
        if (!groups.isEmpty && !incomingRequests.isEmpty && section == 1) || (groups.isEmpty && !incomingRequests.isEmpty && section == 0) {
            return incomingRequests.count
        }
        return friends.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !groups.isEmpty && section == 0 { return "Groups" }
        if (!groups.isEmpty && !incomingRequests.isEmpty && section == 1) || (groups.isEmpty && !incomingRequests.isEmpty && section == 0) {
            return "Friend Requests"
        }
        return "Your Friends"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !groups.isEmpty && indexPath.section == 0 {
            let group = groups[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupcard", for: indexPath) as! GroupCardCell
            cell.configure(with: group)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendcard", for: indexPath) as! FriendCardCell
        let isRequestsSection = (!groups.isEmpty && !incomingRequests.isEmpty && indexPath.section == 1) || (groups.isEmpty && !incomingRequests.isEmpty && indexPath.section == 0)
        if isRequestsSection {
            let user = incomingRequests[indexPath.row]
            cell.configure(with: user, showButton: true, buttonTitle: "Accept")
            cell.onProfileTap = { [weak self] in self?.showProfile(of: user) }
            cell.onButtonTap = { [weak self] in self?.acceptFriendRequest(from: user) }
        } else {
            let user = friends[indexPath.row]
            cell.configure(with: user, showButton: true, buttonTitle: "Message")
            cell.onProfileTap = { [weak self] in self?.showProfile(of: user) }
            cell.onButtonTap = { [weak self] in self?.showChat(with: user) }
        }
        return cell
    }
}

// MARK: - GroupCardCell

class GroupCardCell: UITableViewCell {
    private let card = UIView()
    private let groupImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with group: Group) {
        nameLabel.text = group.name
        descriptionLabel.text = group.description
        if let urlStr = group.imageURL, let url = URL(string: urlStr) {
            groupImageView.image = UIImage(systemName: "person.3.fill")
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data { DispatchQueue.main.async { self.groupImageView.image = UIImage(data: data) } }
            }.resume()
        } else {
            groupImageView.image = UIImage(systemName: "person.3.fill")
        }
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        card.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        contentView.addSubview(card)

        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.layer.cornerRadius = 24
        groupImageView.layer.masksToBounds = true
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        card.addSubview(groupImageView)
        card.addSubview(nameLabel)
        card.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            groupImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            groupImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            groupImageView.widthAnchor.constraint(equalToConstant: 48),
            groupImageView.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.leadingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }
}

// MARK: - FriendCardCell

class FriendCardCell: UITableViewCell {
    private let card = UIView()
    private let avatar = CircleAvatarView()
    private let nameLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    var onButtonTap: (() -> Void)?
    var onProfileTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with user: UserProfile, showButton: Bool, buttonTitle: String) {
        avatar.setInitials(user.displayName)
        nameLabel.text = user.displayName
        actionButton.isHidden = !showButton
        actionButton.setTitle(buttonTitle, for: .normal)
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        card.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
        contentView.addSubview(card)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        actionButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        actionButton.setTitleColor(.systemBlue, for: .normal)
        actionButton.layer.cornerRadius = 10
        actionButton.layer.cornerCurve = .continuous
        actionButton.layer.masksToBounds = true
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)

        card.addSubview(avatar)
        card.addSubview(nameLabel)
        card.addSubview(actionButton)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 48),
            avatar.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            actionButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        avatar.isUserInteractionEnabled = true
        nameLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        avatar.addGestureRecognizer(tap)
        nameLabel.addGestureRecognizer(tap)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    @objc private func buttonTapped() { onButtonTap?() }
    @objc private func profileTapped() { onProfileTap?() }
}

// MARK: - CircleAvatarView

class CircleAvatarView: UIView {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    private func setup() {
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 24
        layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor),
            label.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    func setInitials(_ name: String) {
        let comps = name.split(separator: " ")
        let initials = comps.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        label.text = initials.uppercased()
    }
}

// MARK: - GroupCreateModal


class GroupCreateModal: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    let me: UserProfile
    let friends: [UserProfile]
    var onGroupCreate: ((Group) -> Void)?

    private var selectedFriends: Set<String> = []
    private var groupImage: UIImage?
    private let tableView = UITableView()
    private let nameField = UITextField()
    private let descField = UITextView()
    private let imageView = UIImageView()
    private let createBtn = UIButton(type: .system)

    // Section Cards
    private let photoCard = UIView()
    private let infoCard = UIView()
    private let friendsCard = UIView()

    private let addToGroupLabel = UILabel()
    private let plusIcon = UIImageView(image: UIImage(systemName: "plus.circle.fill"))

    // MARK: - REQUIRED Initializer
    init(me: UserProfile, friends: [UserProfile]) {
        self.me = me
        self.friends = friends
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .formSheet
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground

        setupTopBar()
        setupPhotoCard()
        setupInfoCard()
        setupFriendsCard()
        setupCreateButton()
        animateEntrance()
    }

    // MARK: - UI Setup

    private func setupTopBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Create Group"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = "Create a group and add your friends"
        descLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descLabel.textColor = .secondaryLabel
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeBtn.tintColor = .tertiaryLabel
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            closeBtn.widthAnchor.constraint(equalToConstant: 34),
            closeBtn.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func setupPhotoCard() {
        // Card styling
        photoCard.translatesAutoresizingMaskIntoConstraints = false
        photoCard.layer.cornerRadius = 22
        photoCard.layer.masksToBounds = false
        photoCard.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        photoCard.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.08).cgColor
        photoCard.layer.shadowOpacity = 1.0
        photoCard.layer.shadowRadius = 14
        photoCard.layer.shadowOffset = CGSize(width: 0, height: 4)

        view.addSubview(photoCard)
        NSLayoutConstraint.activate([
            photoCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            photoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            photoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            photoCard.heightAnchor.constraint(equalToConstant: 140)
        ])

        // Group Photo Container - now to the left inside the card
        let groupPhotoContainer = UIView()
        groupPhotoContainer.backgroundColor = UIColor.systemGray6
        groupPhotoContainer.layer.cornerRadius = 16
        groupPhotoContainer.layer.masksToBounds = true
        groupPhotoContainer.translatesAutoresizingMaskIntoConstraints = false
        groupPhotoContainer.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.11).cgColor
        groupPhotoContainer.layer.borderWidth = 1.2

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.image = nil
        groupPhotoContainer.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: groupPhotoContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: groupPhotoContainer.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: groupPhotoContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: groupPhotoContainer.trailingAnchor)
        ])

        plusIcon.tintColor = .systemBlue
        plusIcon.translatesAutoresizingMaskIntoConstraints = false
        groupPhotoContainer.addSubview(plusIcon)
        NSLayoutConstraint.activate([
            plusIcon.trailingAnchor.constraint(equalTo: groupPhotoContainer.trailingAnchor, constant: -5),
            plusIcon.bottomAnchor.constraint(equalTo: groupPhotoContainer.bottomAnchor, constant: -5),
            plusIcon.widthAnchor.constraint(equalToConstant: 28),
            plusIcon.heightAnchor.constraint(equalToConstant: 28)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        groupPhotoContainer.isUserInteractionEnabled = true
        groupPhotoContainer.addGestureRecognizer(tap)

        // Label on right of photo
        let photoLabel = UILabel()
        photoLabel.text = "Add a group photo"
        photoLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        photoLabel.textColor = .label
        photoLabel.translatesAutoresizingMaskIntoConstraints = false

        let photoDesc = UILabel()
        photoDesc.text = "Group photo helps identify your crew!"
        photoDesc.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        photoDesc.textColor = .secondaryLabel
        photoDesc.translatesAutoresizingMaskIntoConstraints = false

        let rightStack = UIStackView(arrangedSubviews: [photoLabel, photoDesc])
        rightStack.axis = .vertical
        rightStack.alignment = .leading
        rightStack.spacing = 7
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        // Arrange photo on left, text on right
        photoCard.addSubview(groupPhotoContainer)
        photoCard.addSubview(rightStack)
        NSLayoutConstraint.activate([
            groupPhotoContainer.leadingAnchor.constraint(equalTo: photoCard.leadingAnchor, constant: 18),
            groupPhotoContainer.centerYAnchor.constraint(equalTo: photoCard.centerYAnchor),
            groupPhotoContainer.widthAnchor.constraint(equalToConstant: 84),
            groupPhotoContainer.heightAnchor.constraint(equalToConstant: 84),

            rightStack.leadingAnchor.constraint(equalTo: groupPhotoContainer.trailingAnchor, constant: 18),
            rightStack.trailingAnchor.constraint(equalTo: photoCard.trailingAnchor, constant: -10),
            rightStack.centerYAnchor.constraint(equalTo: groupPhotoContainer.centerYAnchor)
        ])
    }

    private func setupInfoCard() {
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        infoCard.layer.cornerRadius = 22
        infoCard.layer.masksToBounds = false
        infoCard.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        infoCard.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.08).cgColor
        infoCard.layer.shadowOpacity = 1.0
        infoCard.layer.shadowRadius = 14
        infoCard.layer.shadowOffset = CGSize(width: 0, height: 4)

        view.addSubview(infoCard)
        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: photoCard.bottomAnchor, constant: 20),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoCard.heightAnchor.constraint(equalToConstant: 126)
        ])

        // Name field
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = "Group Name"
        nameField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameField.textAlignment = .left
        nameField.borderStyle = .none
        nameField.backgroundColor = UIColor.systemGray6
        nameField.layer.cornerRadius = 16
        nameField.layer.masksToBounds = true
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 44))
        nameField.leftViewMode = .always
        nameField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Description field
        descField.translatesAutoresizingMaskIntoConstraints = false
        descField.font = UIFont.systemFont(ofSize: 16)
        descField.textColor = .label
        descField.backgroundColor = UIColor.systemGray6
        descField.layer.cornerRadius = 16
        descField.textAlignment = .left
        descField.text = ""
        descField.delegate = self
        descField.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 10, right: 10)
        descField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let fieldsStack = UIStackView(arrangedSubviews: [nameField, descField])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 10
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        infoCard.addSubview(fieldsStack)
        NSLayoutConstraint.activate([
            fieldsStack.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            fieldsStack.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            fieldsStack.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16)
        ])
    }

    private func setupFriendsCard() {
        friendsCard.translatesAutoresizingMaskIntoConstraints = false
        friendsCard.layer.cornerRadius = 22
        friendsCard.layer.masksToBounds = false
        friendsCard.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.97)
        friendsCard.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.08).cgColor
        friendsCard.layer.shadowOpacity = 1.0
        friendsCard.layer.shadowRadius = 14
        friendsCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.addSubview(friendsCard)
        NSLayoutConstraint.activate([
            friendsCard.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 22),
            friendsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            friendsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        addToGroupLabel.text = "Add to Group 🎉"
        addToGroupLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        addToGroupLabel.textColor = .label
        addToGroupLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsCard.addSubview(addToGroupLabel)
        NSLayoutConstraint.activate([
            addToGroupLabel.topAnchor.constraint(equalTo: friendsCard.topAnchor, constant: 18),
            addToGroupLabel.leadingAnchor.constraint(equalTo: friendsCard.leadingAnchor, constant: 18),
            addToGroupLabel.trailingAnchor.constraint(equalTo: friendsCard.trailingAnchor, constant: -18)
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GroupFriendCell.self, forCellReuseIdentifier: "gfc")
        friendsCard.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addToGroupLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: friendsCard.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: friendsCard.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: friendsCard.bottomAnchor, constant: -12),
            tableView.heightAnchor.constraint(equalToConstant: min(CGFloat(friends.count) * 56, 196))
        ])
    }

    private func setupCreateButton() {
        createBtn.translatesAutoresizingMaskIntoConstraints = false
        createBtn.setTitle("Create Group", for: .normal)
        createBtn.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        createBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
        createBtn.setTitleColor(.systemBlue, for: .normal)
        createBtn.layer.cornerRadius = 16
        createBtn.layer.cornerCurve = .continuous
        createBtn.addTarget(self, action: #selector(createGroup), for: .touchUpInside)
        createBtn.addTarget(self, action: #selector(animateCreateBtnDown), for: .touchDown)
        createBtn.addTarget(self, action: #selector(animateCreateBtnUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        view.addSubview(createBtn)
        NSLayoutConstraint.activate([
            createBtn.topAnchor.constraint(equalTo: friendsCard.bottomAnchor, constant: 30),
            createBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createBtn.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func animateEntrance() {
        // Cards fade and slide in for a lively feel
        [photoCard, infoCard, friendsCard].forEach { card in
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 60)
        }
        UIView.animate(withDuration: 0.7, delay: 0.07, usingSpringWithDamping: 0.67, initialSpringVelocity: 0.5, options: [], animations: {
            self.photoCard.alpha = 1
            self.photoCard.transform = .identity
        }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.18, usingSpringWithDamping: 0.67, initialSpringVelocity: 0.5, options: [], animations: {
            self.infoCard.alpha = 1
            self.infoCard.transform = .identity
        }, completion: nil)
        UIView.animate(withDuration: 0.7, delay: 0.29, usingSpringWithDamping: 0.67, initialSpringVelocity: 0.5, options: [], animations: {
            self.friendsCard.alpha = 1
            self.friendsCard.transform = .identity
        }, completion: nil)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { friends.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "gfc", for: indexPath) as! GroupFriendCell
        cell.configure(with: user, selected: selectedFriends.contains(user.uid))
        cell.onToggle = { [weak self, weak cell] isOn in
            guard let self = self else { return }
            if isOn { self.selectedFriends.insert(user.uid) }
            else { self.selectedFriends.remove(user.uid) }
            UIView.animate(withDuration: 0.25) {
                cell?.contentView.backgroundColor = isOn ? UIColor.systemBlue.withAlphaComponent(0.09) : .clear
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? GroupFriendCell {
            cell.toggleSwitch()
        }
    }

    // MARK: - Actions

    @objc private func createGroup() {
        guard let name = nameField.text, !name.isEmpty, !selectedFriends.isEmpty else { return }
        var memberUIDs = Array(selectedFriends)
        memberUIDs.append(me.uid)
        let groupID = UUID().uuidString
        let desc = descField.text ?? ""
        if let groupImage = groupImage {
            uploadGroupImage(groupImage, groupId: groupID) { [weak self] url in
                let group = Group(id: groupID, name: name, description: desc, imageURL: url, memberUIDs: memberUIDs)
                self?.cheerfulCompletion()
                self?.onGroupCreate?(group)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    self?.dismiss(animated: true)
                }
            }
        } else {
            let group = Group(id: groupID, name: name, description: desc, imageURL: nil, memberUIDs: memberUIDs)
            cheerfulCompletion()
            onGroupCreate?(group)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                self.dismiss(animated: true)
            }
        }
    }

    private func cheerfulCompletion() {
        let confetti = ConfettiView(frame: view.bounds)
        view.addSubview(confetti)
        confetti.emit()
    }

    @objc private func selectImage() {
        UIView.animate(withDuration: 0.18, animations: {
            self.plusIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2).scaledBy(x: 1.18, y: 1.18)
        }) { _ in
            UIView.animate(withDuration: 0.21) {
                self.plusIcon.transform = .identity
            }
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            imageView.image = img
            groupImage = img
        }
        dismiss(animated: true)
    }

    @objc private func close() { dismiss(animated: true) }

    // MARK: - Animated Button
    @objc private func animateCreateBtnDown() {
        UIView.animate(withDuration: 0.12) {
            self.createBtn.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    @objc private func animateCreateBtnUp() {
        UIView.animate(withDuration: 0.15) {
            self.createBtn.transform = .identity
        }
    }

    // MARK: - Upload Helper

    func uploadGroupImage(_ image: UIImage, groupId: String, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("groupImages/\(groupId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard error == nil else {
                print("Upload error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("URL error: \(error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                    return
                }
                completion(url.absoluteString)
            }
        }
    }
}

class GroupFriendCell: UITableViewCell {
    private let avatar = CircleAvatarView()
    private let nameLabel = UILabel()
    private let check = UISwitch()
    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with user: UserProfile, selected: Bool) {
        avatar.setInitials(user.displayName)
        nameLabel.text = user.displayName
        check.isOn = selected
    }
    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        avatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        check.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(check)
        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 38),
            avatar.heightAnchor.constraint(equalToConstant: 38),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            check.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            check.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        check.onTintColor = UIColor.systemBlue
        check.addTarget(self, action: #selector(toggle), for: .valueChanged)
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        addGestureRecognizer(bgTap)
    }
    @objc private func toggle() {
        check.setOn(!check.isOn, animated: true)
        onToggle?(check.isOn)
    }
    func toggleSwitch() {
        toggle()
    }
}

// MARK: - Fun Confetti Animation View

class ConfettiView: UIView {
    private var emitter: CAEmitterLayer?
    func emit() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -16)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        let colors: [UIColor] = [.systemBlue, .systemPurple, .systemGreen, .systemOrange, .systemPink, .systemYellow]
        let emojis = ["🎉", "🎊", "✨", "🥳", "🌈", "⭐️"]
        var cells: [CAEmitterCell] = []
        for i in 0..<7 {
            let cell = CAEmitterCell()
            cell.birthRate = 2
            cell.lifetime = 2.6
            cell.velocity = 160
            cell.velocityRange = 60
            cell.emissionLongitude = .pi
            cell.emissionRange = 0.9
            cell.spin = 1
            cell.spinRange = 1.5
            cell.scale = 1.1
            cell.scaleRange = 0.6
            cell.contents = NSAttributedString(string: emojis[i % emojis.count], attributes: [.font: UIFont.systemFont(ofSize: 32)]).image()?.cgImage
            cell.color = colors[i % colors.count].cgColor
            cells.append(cell)
        }
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        self.emitter = emitter
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            emitter.birthRate = 0
            emitter.removeFromSuperlayer()
            self.removeFromSuperview()
        }
    }
}

// Helper to convert NSAttributedString emoji to UIImage for CAEmitterCell
extension NSAttributedString {
    func image() -> UIImage? {
        let size = CGSize(width: 36, height: 36)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}


// MARK: - FriendSearchModal

class FriendSearchModal: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var onSendRequest: ((UserProfile) -> Void)?
    var onProfileTap: ((UserProfile) -> Void)?
    private let db = Firestore.firestore()
    private let currentUser: UserProfile?
    private let knownIds: Set<String>
    private var users: [UserProfile] = []
    private var allUsers: [UserProfile] = []
    private var sentRequests: Set<String> = []
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let loading = UIActivityIndicatorView(style: .medium)

    init(currentUser: UserProfile?, friends: [UserProfile], incomingRequests: [UserProfile]) {
        self.currentUser = currentUser
        let ids = [currentUser?.uid] + friends.map { $0.uid }
        self.knownIds = Set(ids.compactMap { $0 })
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .formSheet
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
        fetchSentRequestsAndAllUsers()
    }

    private func setupUI() {
        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeBtn.tintColor = .tertiaryLabel
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            closeBtn.widthAnchor.constraint(equalToConstant: 34),
            closeBtn.heightAnchor.constraint(equalToConstant: 34)
        ])

        searchBar.placeholder = "Search users"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            searchBar.heightAnchor.constraint(equalToConstant: 48)
        ])

        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 30
        cardView.layer.cornerCurve = .continuous
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.93)
        cardView.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.06).cgColor
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowRadius = 18
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        let blurView: UIVisualEffectView = {
            let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
            let v = UIVisualEffectView(effect: blur)
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        cardView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        loading.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 78
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(FriendCardCellSheet.self, forCellReuseIdentifier: "friendcard")
        tableView.dataSource = self
        tableView.delegate = self
        cardView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
    }

    private func fetchSentRequestsAndAllUsers() {
        guard let myUid = currentUser?.uid else { return }
        loading.startAnimating()
        db.collection("users").document(myUid).collection("sentFriendRequests").getDocuments { [weak self] snap, _ in
            guard let self = self else { return }
            let sentTo = snap?.documents.map { $0.documentID } ?? []
            self.sentRequests = Set(sentTo)
            self.fetchAllUsers()
        }
    }

    private func fetchAllUsers() {
        db.collection("users").getDocuments { [weak self] snap, error in
            guard let self = self else { return }
            let docs = snap?.documents ?? []
            self.allUsers = docs.compactMap { UserProfile(from: $0.data()) }
                .filter { !self.knownIds.contains($0.uid) }
            self.users = self.allUsers
            self.loading.stopAnimating()
            self.tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            users = allUsers
            tableView.reloadData()
            return
        }
        users = allUsers.filter { $0.displayName.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let alreadyRequested = sentRequests.contains(user.uid)
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendcard", for: indexPath) as! FriendCardCellSheet
        cell.configure(with: user, alreadyRequested: alreadyRequested)
        cell.onButtonTap = { [weak self, weak cell] in
            guard let self = self else { return }
            guard !self.sentRequests.contains(user.uid) else { return }
            self.sendFriendRequest(to: user) {
                cell?.animateToTick()
                self.sentRequests.insert(user.uid)
            }
        }
        cell.onProfileTap = { [weak self] in self?.onProfileTap?(user) }
        cell.onTickTap = { [weak self, weak cell] in
            guard let self = self else { return }
            guard self.sentRequests.contains(user.uid) else { return }
            self.revokeFriendRequest(to: user) {
                cell?.animateToSendRequest()
                self.sentRequests.remove(user.uid)
            }
        }
        return cell
    }

    private func sendFriendRequest(to user: UserProfile, completion: @escaping () -> Void) {
        guard let myProfile = currentUser else { return }
        db.collection("users").document(user.uid)
            .collection("friendRequests").document(myProfile.uid)
            .setData(myProfile.dictionary) { [weak self] error in
                guard let self = self else { return }
                if error == nil {
                    self.db.collection("users").document(myProfile.uid)
                        .collection("sentFriendRequests").document(user.uid)
                        .setData(user.dictionary) { _ in
                            completion()
                        }
                }
            }
    }

    private func revokeFriendRequest(to user: UserProfile, completion: @escaping () -> Void) {
        guard let myProfile = currentUser else { return }
        db.collection("users").document(myProfile.uid)
            .collection("sentFriendRequests").document(user.uid)
            .delete { [weak self] _ in
                guard let self = self else { return }
                self.db.collection("users").document(user.uid)
                    .collection("friendRequests").document(myProfile.uid)
                    .delete { _ in
                        completion()
                    }
            }
    }

    @objc private func close() { dismiss(animated: true) }
}

class FriendCardCellSheet: UITableViewCell {
    private let card = UIView()
    private let avatar = CircleAvatarView()
    private let nameLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let tickImage = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
    var onButtonTap: (() -> Void)?
    var onProfileTap: (() -> Void)?
    var onTickTap: (() -> Void)?

    private var alreadyRequested = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with user: UserProfile, alreadyRequested: Bool) {
        avatar.setInitials(user.displayName)
        nameLabel.text = user.displayName
        self.alreadyRequested = alreadyRequested
        actionButton.isHidden = alreadyRequested
        tickImage.isHidden = !alreadyRequested
        actionButton.setTitle("Send Request", for: .normal)
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        card.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
        contentView.addSubview(card)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        tickImage.translatesAutoresizingMaskIntoConstraints = false
        tickImage.tintColor = UIColor.systemGreen
        tickImage.contentMode = .scaleAspectFit
        tickImage.isHidden = true

        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        actionButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        actionButton.setTitleColor(.systemBlue, for: .normal)
        actionButton.layer.cornerRadius = 10
        actionButton.layer.cornerCurve = .continuous
        actionButton.layer.masksToBounds = true
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)

        card.addSubview(avatar)
        card.addSubview(nameLabel)
        card.addSubview(actionButton)
        card.addSubview(tickImage)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 48),
            avatar.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            actionButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            tickImage.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            tickImage.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            tickImage.widthAnchor.constraint(equalToConstant: 30),
            tickImage.heightAnchor.constraint(equalToConstant: 30)
        ])

        avatar.isUserInteractionEnabled = true
        nameLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        avatar.addGestureRecognizer(tap)
        nameLabel.addGestureRecognizer(tap)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        tickImage.isUserInteractionEnabled = true
        let tickTap = UITapGestureRecognizer(target: self, action: #selector(tickTapped))
        tickImage.addGestureRecognizer(tickTap)
    }

    @objc private func buttonTapped() {
        guard !alreadyRequested else { return }
        onButtonTap?()
    }
    @objc private func profileTapped() { onProfileTap?() }
    @objc private func tickTapped() { onTickTap?() }

    func animateToTick() {
        actionButton.isUserInteractionEnabled = false
        UIView.transition(with: actionButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.actionButton.isHidden = true
        }) { _ in
            self.tickImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.tickImage.isHidden = false
            UIView.animate(withDuration: 0.25,
                           delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8,
                           options: [], animations: {
                self.tickImage.transform = .identity
            }, completion: nil)
        }
    }

    func animateToSendRequest() {
        tickImage.isUserInteractionEnabled = false
        UIView.transition(with: tickImage, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.tickImage.isHidden = true
        }) { _ in
            self.actionButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.actionButton.isHidden = false
            UIView.animate(withDuration: 0.22,
                           delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.7,
                           options: [], animations: {
                self.actionButton.transform = .identity
            }, completion: { _ in
                self.actionButton.isUserInteractionEnabled = true
                self.tickImage.isUserInteractionEnabled = true
            })
        }
    }
}

// MARK: - FriendProfileViewController

class FriendProfileViewController: UIViewController {
    let user: UserProfile
    let canMessage: Bool
    var onMessageTap: (() -> Void)?
    init(user: UserProfile, canMessage: Bool) {
        self.user = user
        self.canMessage = canMessage
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .formSheet
    }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        let avatar = CircleAvatarView()
        avatar.setInitials(user.displayName)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 48
        avatar.layer.masksToBounds = true
        let nameLabel = UILabel()
        nameLabel.text = user.displayName
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [avatar, nameLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48)
        ])
        if canMessage {
            let msgBtn = UIButton(type: .system)
            msgBtn.setTitle("Message", for: .normal)
            msgBtn.setTitleColor(.white, for: .normal)
            msgBtn.backgroundColor = .systemBlue
            msgBtn.layer.cornerRadius = 14
            msgBtn.layer.cornerCurve = .continuous
            msgBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            msgBtn.translatesAutoresizingMaskIntoConstraints = false
            msgBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            msgBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true
            msgBtn.addTarget(self, action: #selector(msgTapped), for: .touchUpInside)
            stack.addArrangedSubview(msgBtn)
        }
    }
    @objc private func msgTapped() { onMessageTap?() }
}


