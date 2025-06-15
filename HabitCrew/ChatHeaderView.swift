import UIKit
import FirebaseFirestore

class ChatHeaderView: UIView {
    // MARK: - UI Elements
    let backButton = UIButton(type: .system)
    let avatarView = UIImageView()
    let initialLabel = UILabel()
    let nameLabel = UILabel()
    let subtitleLabel = UILabel()
    private let onlineDot = UIView()
    private let gradientLayer = CAGradientLayer()
    private var statusListener: ListenerRegistration?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.93, green: 0.97, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.91, green: 0.94, blue: 1, alpha: 0.96).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.10, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.8)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupSubviews() {
        backgroundColor = .clear
        layer.cornerRadius = 24
        layer.masksToBounds = false
        layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.07).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        backButton.tintColor = .systemBlue
        backButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        backButton.layer.cornerRadius = 16
        backButton.layer.masksToBounds = true
        backButton.translatesAutoresizingMaskIntoConstraints = false

        avatarView.layer.cornerRadius = 22
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.19).cgColor
        avatarView.backgroundColor = UIColor.systemGray5
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.isUserInteractionEnabled = false

        // Initial Label inside avatarView
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        initialLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        initialLabel.textColor = .systemBlue
        initialLabel.textAlignment = .center
        initialLabel.isHidden = true
        avatarView.addSubview(initialLabel)

        onlineDot.translatesAutoresizingMaskIntoConstraints = false
        onlineDot.layer.cornerRadius = 7
        onlineDot.layer.masksToBounds = true
        onlineDot.backgroundColor = UIColor.systemGray3
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor.white.cgColor

        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backButton)
        addSubview(avatarView)
        avatarView.addSubview(onlineDot)
        addSubview(nameLabel)
        addSubview(subtitleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 35),
            backButton.heightAnchor.constraint(equalToConstant: 35),

            avatarView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),

            initialLabel.leadingAnchor.constraint(equalTo: avatarView.leadingAnchor),
            initialLabel.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor),
            initialLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            initialLabel.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),

            onlineDot.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -3),
            onlineDot.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: -3),
            onlineDot.widthAnchor.constraint(equalToConstant: 14),
            onlineDot.heightAnchor.constraint(equalToConstant: 14),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 7),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    // MARK: - Public API
    /// If avatar is nil, shows initial instead
    func configure(name: String, avatar: UIImage?, subtitle: String?) {
        nameLabel.text = name
        if let avatar = avatar {
            avatarView.image = avatar
            initialLabel.isHidden = true
        } else {
            avatarView.image = nil
            initialLabel.isHidden = false
            initialLabel.text = name.first.map { String($0).uppercased() } ?? "?"
        }
        setSubtitle(subtitle)
    }

    func setSubtitle(_ text: String?) {
        subtitleLabel.text = text
        if let text = text, text.lowercased().contains("online") {
            onlineDot.backgroundColor = UIColor.systemGreen
        } else {
            onlineDot.backgroundColor = UIColor.systemGray3
        }
    }

    /// Start live status updates for a user
    func bindToUserStatus(uid: String) {
        statusListener?.remove()
        let db = Firestore.firestore()
        statusListener = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self else { return }
                let isOnline = (snap?.data()?["isOnline"] as? Bool) ?? false
                let lastSeen = (snap?.data()?["lastSeen"] as? Timestamp)?.dateValue()
                if isOnline {
                    self.setSubtitle("Online")
                } else if let lastSeen = lastSeen {
                    let formatter = RelativeDateTimeFormatter()
                    self.setSubtitle("Last seen \(formatter.localizedString(for: lastSeen, relativeTo: Date()))")
                } else {
                    self.setSubtitle("Offline")
                }
            }
    }

    /// Remove the Firestore listener when done
    func unbindStatus() {
        statusListener?.remove()
        statusListener = nil
    }
}

#Preview{
    ChatHeaderView()
}
