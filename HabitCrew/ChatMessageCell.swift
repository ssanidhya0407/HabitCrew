import UIKit
import AVFoundation


enum ChatMessageKind {
    case text(String)
    case photo(URL)
    case voice(url: URL, duration: TimeInterval)
}

protocol ChatMessageCellDelegate: AnyObject {
    func chatMessageCell(_ cell: ChatMessageCell, didTapImage image: UIImage)
    func chatMessageCell(_ cell: ChatMessageCell, didTapAudio url: URL)
    func chatMessageCellShouldStopAudio(_ cell: ChatMessageCell)
}

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    weak var delegate: ChatMessageCellDelegate?

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let photoImageView = UIImageView()
    private let playButton = UIButton(type: .system)
    private let durationLabel = UILabel()
    private let waveformView = LiveWaveformView()
    private var playbackTimer: Timer?
    private var voiceURL: URL?
    private var isPlaying: Bool = false

    private var photoWidth: NSLayoutConstraint?
    private var photoHeight: NSLayoutConstraint?
    private var voiceContainer: UIStackView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.masksToBounds = true
        contentView.addSubview(bubbleView)

        // Text
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        bubbleView.addSubview(messageLabel)

        // Photo
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 14
        photoImageView.clipsToBounds = true
        photoImageView.isUserInteractionEnabled = true
        bubbleView.addSubview(photoImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap))
        photoImageView.addGestureRecognizer(tap)

        // Voice
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = .systemBlue
        playButton.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        durationLabel.textColor = .secondaryLabel

        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.isHidden = false

        // Voice container stack
        voiceContainer = UIStackView(arrangedSubviews: [playButton, waveformView, durationLabel])
        voiceContainer.axis = .horizontal
        voiceContainer.alignment = .center
        voiceContainer.spacing = 8
        voiceContainer.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(voiceContainer)
    }

    private func setupConstraints() {
        // BubbleView
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.65)
        ])

        // Text
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
        ])

        // Photo (square)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
        ])
        photoWidth = photoImageView.widthAnchor.constraint(equalToConstant: 200)
        photoHeight = photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor)
        photoWidth?.isActive = false
        photoHeight?.isActive = false

        // Voice
        NSLayoutConstraint.activate([
            voiceContainer.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            voiceContainer.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            voiceContainer.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            voiceContainer.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            playButton.widthAnchor.constraint(equalToConstant: 32),
            playButton.heightAnchor.constraint(equalToConstant: 32),
            waveformView.heightAnchor.constraint(equalToConstant: 26),
            waveformView.widthAnchor.constraint(equalToConstant: 80),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
        photoImageView.image = nil
        photoWidth?.isActive = false
        photoHeight?.isActive = false
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        durationLabel.text = nil
        waveformView.reset()
        voiceContainer.isHidden = true
        messageLabel.isHidden = true
        photoImageView.isHidden = true
        bubbleView.backgroundColor = nil
        playbackTimer?.invalidate()
        isPlaying = false
    }

    func configure(kind: ChatMessageKind, isOutgoing: Bool, duration: TimeInterval? = nil) {
        // Bubble color and alignment
        if isOutgoing {
            bubbleView.backgroundColor = UIColor(red: 0.75, green: 0.88, blue: 1, alpha: 1)
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100).isActive = false
        } else {
            bubbleView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100).isActive = false
        }

        // Hide all content
        messageLabel.isHidden = true
        photoImageView.isHidden = true
        voiceContainer.isHidden = true
        photoWidth?.isActive = false
        photoHeight?.isActive = false
        isPlaying = false

        switch kind {
        case .text(let text):
            messageLabel.isHidden = false
            messageLabel.text = text

        case .photo(let url):
            photoImageView.isHidden = false
            photoWidth?.isActive = true
            photoHeight?.isActive = true
            photoImageView.image = nil
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.photoImageView.image = image
                }
            }.resume()

        case .voice(let url, let duration):
            voiceContainer.isHidden = false
            voiceURL = url
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            waveformView.reset()
            if duration == 0 {
                fetchVoiceDuration(url: url)
            } else {
                durationLabel.text = formatDuration(duration)
            }
        }
    }

    private func fetchVoiceDuration(url: URL) {
        DispatchQueue.global().async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                let player = try AVAudioPlayer(data: data)
                let duration = player.duration
                DispatchQueue.main.async {
                    self?.durationLabel.text = self?.formatDuration(duration)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.durationLabel.text = "0:00"
                }
            }
        }
    }

    @objc private func handlePhotoTap() {
        if let image = photoImageView.image {
            delegate?.chatMessageCell(self, didTapImage: image)
        }
    }

    @objc private func handlePlayTapped() {
        guard let url = voiceURL else { return }
        delegate?.chatMessageCell(self, didTapAudio: url)
    }

    // Called by controller
    func setPlaying(_ playing: Bool) {
        isPlaying = playing
        if playing {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            animateWaveformDuringPlayback()
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            stopWaveformAnimation()
        }
    }

    private func animateWaveformDuringPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak self] timer in
            guard let self = self, self.isPlaying else { timer.invalidate(); return }
            let level: Float = Float.random(in: 0.25...1.0)
            self.waveformView.update(with: level)
        }
    }
    private func stopWaveformAnimation() {
        playbackTimer?.invalidate()
        waveformView.reset()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let min = Int(duration) / 60
        let sec = Int(duration) % 60
        return String(format: "%d:%02d", min, sec)
    }
}

extension ChatMessageCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        stopWaveformAnimation()
    }
}

extension ChatMessageCell {
    static func avatarImageForName(_ name: String) -> UIImage? {
        let size = CGSize(width: 36, height: 36)
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = String(name.prefix(1)).uppercased()
        label.backgroundColor = .systemGray5
        label.textColor = .systemBlue
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
