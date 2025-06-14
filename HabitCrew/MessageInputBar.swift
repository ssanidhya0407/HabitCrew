import UIKit

protocol MessageInputBarDelegate: AnyObject {
    func didSendText(_ text: String)
    func didTapPhoto()
    func didStartRecording()
    func didStopRecording()
    func didSendCheckin(_ checkin: CheckinData)
    func didSendNudge(_ nudge: String)
    func didSendSummary(_ summary: SummaryData)
}

class MessageInputBar: UIView, UITextViewDelegate {
    weak var delegate: MessageInputBarDelegate?
    var me: UserProfile?

    private let bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        return v
    }()

    private let plusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = UIColor.systemBlue
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return btn
    }()

    private let inputTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tv.textColor = .label
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.layer.cornerRadius = 22
        tv.layer.masksToBounds = true
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        tv.isScrollEnabled = false
        tv.returnKeyType = .send
        return tv
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        btn.tintColor = UIColor.systemBlue
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return btn
    }()

    private let photoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        btn.tintColor = UIColor.systemBlue
        btn.alpha = 0
        btn.isHidden = true
        btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return btn
    }()

    private let micButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        btn.tintColor = UIColor.systemBlue
        btn.alpha = 0
        btn.isHidden = true
        btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return btn
    }()

    private let checkinButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        btn.tintColor = UIColor.systemGreen
        btn.alpha = 0
        btn.isHidden = true
        btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return btn
    }()

    private let nudgeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "hand.point.up.left.fill"), for: .normal)
        btn.tintColor = UIColor.systemOrange
        btn.alpha = 0
        btn.isHidden = true
        btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return btn
    }()

    private var inputHeightConstraint: NSLayoutConstraint!
    private var optionButtonLeadingConstraints: [NSLayoutConstraint] = []

    private var isOptionsVisible = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        addSubview(bgView)
        bgView.addSubview(plusButton)
        bgView.addSubview(inputTextView)
        bgView.addSubview(sendButton)
        bgView.addSubview(photoButton)
        bgView.addSubview(micButton)
        bgView.addSubview(checkinButton)
        bgView.addSubview(nudgeButton)

        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Plus button at the far left
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 8),
            plusButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
        ])

        // Option buttons, initially "stacked" on top of the plus
        let optionButtons = [photoButton, micButton, checkinButton, nudgeButton]
        optionButtonLeadingConstraints = []
        for (i, btn) in optionButtons.enumerated() {
            let leading = btn.leadingAnchor.constraint(equalTo: plusButton.leadingAnchor)
            optionButtonLeadingConstraints.append(leading)
            NSLayoutConstraint.activate([
                leading,
                btn.centerYAnchor.constraint(equalTo: bgView.centerYAnchor)
            ])
        }

        // Input field to the right of the plus
        inputHeightConstraint = inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        NSLayoutConstraint.activate([
            inputTextView.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 8),
            inputTextView.topAnchor.constraint(greaterThanOrEqualTo: bgView.topAnchor, constant: 8),
            inputTextView.bottomAnchor.constraint(lessThanOrEqualTo: bgView.bottomAnchor, constant: -8),
            inputHeightConstraint
        ])

        // Send button at the far right
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: inputTextView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
        ])

        // Vertically center input field
        NSLayoutConstraint.activate([
            inputTextView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor)
        ])

        // Actions
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
        inputTextView.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(didTapMic), for: .touchDown)
        micButton.addTarget(self, action: #selector(didReleaseMic), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        checkinButton.addTarget(self, action: #selector(didTapCheckin), for: .touchUpInside)
        nudgeButton.addTarget(self, action: #selector(didTapNudge), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keeps the bar above the keyboard on devices with home indicator
        let bottomInset = safeAreaInsets.bottom
        bgView.layoutIfNeeded()
        self.frame.size.height = 64 + bottomInset
    }

    // MARK: - Expandable Options

    @objc private func didTapPlus() {
        isOptionsVisible.toggle()
        let optionButtons = [photoButton, micButton, checkinButton, nudgeButton]
        let spacing: CGFloat = 44

        for (i, btn) in optionButtons.enumerated() {
            btn.isHidden = false
            // Change leading constraint for animation
            optionButtonLeadingConstraints[i].constant = isOptionsVisible ? spacing * CGFloat(i + 1) : 0        }

        UIView.animate(withDuration: 0.25, animations: {
            for btn in optionButtons {
                btn.alpha = self.isOptionsVisible ? 1 : 0
            }
            let plusImage = self.isOptionsVisible
                ? UIImage(systemName: "xmark.circle.fill")
                : UIImage(systemName: "plus.circle.fill")
            self.plusButton.setImage(plusImage, for: .normal)
            self.layoutIfNeeded()
        }) { _ in
            if !self.isOptionsVisible {
                for btn in optionButtons { btn.isHidden = true }
            }
        }
    }

    // MARK: - Actions

    @objc private func didTapSend() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        delegate?.didSendText(text)
        inputTextView.text = ""
        textViewDidChange(inputTextView)
    }
    @objc private func didTapPhoto() {
        delegate?.didTapPhoto()
    }
    @objc private func didTapMic() {
        delegate?.didStartRecording()
    }
    @objc private func didReleaseMic() {
        delegate?.didStopRecording()
    }
    @objc private func didTapCheckin() {
        // Provide all required fields for your CheckinData struct
        let checkin = CheckinData(
            habitName: "Example Habit",
            date: Date(),
            status: "completed",
            note: nil
        )
        delegate?.didSendCheckin(checkin)
    }
    @objc private func didTapNudge() {
        delegate?.didSendNudge("Don't forget to check-in!")
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        let height = max(44, min(100, textView.contentSize.height))
        inputHeightConstraint.constant = height
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
