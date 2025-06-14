import UIKit

class ChatMessageCell: UITableViewCell {
    private let bubble = UIView()
    private let messageLabel = UILabel()
    private let photoView = UIImageView()
    private let timeLabel = UILabel()
    private let avatarView = UIImageView()
    private var bubbleLeading: NSLayoutConstraint!
    private var bubbleTrailing: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with msg: HabitMessage, isMe: Bool, parent: ChatViewController) {
        // Alignment
        bubbleLeading.isActive = !isMe
        bubbleTrailing.isActive = isMe

        // Bubble color & text
        bubble.backgroundColor = isMe
            ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) // iMessage blue
            : UIColor(white: 0.93, alpha: 1.0) // iMessage incoming gray
        messageLabel.textColor = isMe ? .white : .black

        // Bubble shape (rounded, iMessage style)
        bubble.layer.cornerRadius = 22
        bubble.layer.maskedCorners = isMe
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        bubble.layer.masksToBounds = true
        bubble.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        bubble.layer.shadowOpacity = 1.0
        bubble.layer.shadowRadius = 2
        bubble.layer.shadowOffset = CGSize(width: 0, height: 1)

        // Reset
        photoView.isHidden = true
        messageLabel.isHidden = false

        // Content
        switch msg.type {
        case .text:
            messageLabel.text = msg.content
        case .checkin:
            messageLabel.text = "✅ Check-in: \(msg.checkinData?.habitName ?? "")"
        case .nudge:
            messageLabel.text = "👉 Nudge: \(msg.content ?? "")"
        case .voice:
            messageLabel.text = "🎤 Voice message"
        case .image:
            photoView.isHidden = false
            messageLabel.isHidden = true
            if let urlStr = msg.content, let url = URL(string: urlStr) {
                photoView.image = UIImage(systemName: "photo")
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.photoView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        default:
            messageLabel.text = msg.content ?? ""
        }

        // Timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: msg.timestamp)
        timeLabel.textColor = .secondaryLabel

        // Avatar (optional, only for incoming)
        avatarView.isHidden = isMe
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        bubble.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        photoView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        bubble.addSubview(photoView)
        bubble.addSubview(messageLabel)
        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        contentView.addSubview(avatarView)

        // Avatar (left, only for incoming)
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            avatarView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 34),
            avatarView.heightAnchor.constraint(equalToConstant: 34)
        ])
        avatarView.layer.cornerRadius = 17
        avatarView.layer.masksToBounds = true
        avatarView.backgroundColor = UIColor.systemGray5

        // Bubble constraints
        bubbleLeading = bubble.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 4)
        bubbleTrailing = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 265),
            bubble.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -2),
        ])

        // Message label & photo
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 13),
            messageLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 17),
            messageLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -17),
            messageLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -13),

            photoView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 7),
            photoView.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 7),
            photoView.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -7),
            photoView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -7),
            photoView.widthAnchor.constraint(equalToConstant: 210),
            photoView.heightAnchor.constraint(equalToConstant: 140),
        ])
        photoView.contentMode = .scaleAspectFill
        photoView.layer.cornerRadius = 15
        photoView.layer.masksToBounds = true

        // Time label below bubble
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 11),
            timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -11),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            timeLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        timeLabel.font = .systemFont(ofSize: 12)
    }
}
