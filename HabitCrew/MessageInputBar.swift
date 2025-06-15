import UIKit

protocol MessageInputBarDelegate: AnyObject {
    func didSendText(_ text: String)
    func didTapPhoto()
    func didStartRecording()
    func didStopRecording(cancelled: Bool)
}

class MessageInputBar: UIView, UITextViewDelegate {
    weak var delegate: MessageInputBarDelegate?

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let stack = UIStackView()
    private let photoButton = UIButton(type: .system)
    private let inputContainer = UIView()
    private let inputTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let sendButton = UIButton(type: .system)
    private let micButton = UIButton(type: .system)
    private let waveformView = LiveWaveformView()
    private var inputHeightConstraint: NSLayoutConstraint!
    private var isRecording = false
    private var waveformTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 26
        blurView.clipsToBounds = true
        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 7),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -7)
        ])

        photoButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        photoButton.tintColor = .systemBlue
        photoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        photoButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        inputContainer.backgroundColor = UIColor(white: 0.92, alpha: 1)
        inputContainer.layer.cornerRadius = 22
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true

        inputTextView.font = UIFont.systemFont(ofSize: 17)
        inputTextView.backgroundColor = .clear
        inputTextView.textColor = .label
        inputTextView.layer.cornerRadius = 22
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        inputTextView.isScrollEnabled = false
        inputTextView.returnKeyType = .send
        inputTextView.delegate = self
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.isEditable = true // <-- Crucial for typing!

        inputContainer.addSubview(inputTextView)
        NSLayoutConstraint.activate([
            inputTextView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            inputTextView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            inputTextView.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            inputTextView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor)
        ])

        placeholderLabel.text = "Message..."
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 18),
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 10)
        ])
        placeholderLabel.isHidden = !inputTextView.text.isEmpty

        inputHeightConstraint = inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        inputHeightConstraint.isActive = true

        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        sendButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micButton.tintColor = .systemBlue
        micButton.addTarget(self, action: #selector(micTouchDown), for: .touchDown)
        micButton.addTarget(self, action: #selector(micTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        micButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        micButton.heightAnchor.constraint(equalToConstant: 34).isActive = true

        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.isHidden = true
        waveformView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        waveformView.heightAnchor.constraint(equalToConstant: 26).isActive = true

        stack.addArrangedSubview(photoButton)
        stack.addArrangedSubview(inputContainer)
        stack.addArrangedSubview(sendButton)
        stack.addArrangedSubview(micButton)
        stack.addArrangedSubview(waveformView)
    }

    // MARK: - Animations & Recording
    @objc private func didTapPhoto() {
        delegate?.didTapPhoto()
    }
    @objc private func didTapSend() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        delegate?.didSendText(text)
        inputTextView.text = ""
        textViewDidChange(inputTextView)
    }
    @objc private func micTouchDown() {
        guard !isRecording else { return }
        isRecording = true
        inputContainer.isHidden = true
        sendButton.isHidden = true
        waveformView.isHidden = false
        startWaveformAnimation()
        delegate?.didStartRecording()
    }
    @objc private func micTouchUp() {
        guard isRecording else { return }
        isRecording = false
        inputContainer.isHidden = false
        sendButton.isHidden = false
        waveformView.isHidden = true
        stopWaveformAnimation()
        delegate?.didStopRecording(cancelled: false)
    }
    private func startWaveformAnimation() {
        waveformTimer?.invalidate()
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { [weak self] _ in
            let level: Float = Float.random(in: 0.2...1)
            self?.waveformView.update(with: level)
        }
    }
    private func stopWaveformAnimation() {
        waveformTimer?.invalidate()
        waveformView.reset()
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let height = max(44, min(100, textView.contentSize.height))
        inputHeightConstraint.constant = height
        placeholderLabel.isHidden = !textView.text.isEmpty
        layoutIfNeeded()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            didTapSend()
            return false
        }
        return true
    }
}
