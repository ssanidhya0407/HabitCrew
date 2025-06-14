import UIKit

class ForgotPasswordSheetViewController: UIViewController {
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let emailField = UITextField()
    let sendButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    let iconView = UIImageView()
    let bottomLabel = UILabel()
    let waveLayer = CAShapeLayer()
    var onSend: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 28
        view.clipsToBounds = true

        // Add wave at the very bottom
        addBottomWave()

        // Icon
        iconView.image = UIImage(systemName: "paperplane.circle.fill")
        iconView.tintColor = UIColor.systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // Title & Desc
        titleLabel.text = "Reset Password"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center

        descLabel.text = "Enter your email address to receive a password reset link."
        descLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0

        // Email (rectangular like other screens)
        configureRectangularTextField(emailField, placeholder: "Email")

        // Send Button
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 11
        sendButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        // Cancel Button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // Bottom Message
        bottomLabel.text = "We’ll help you get back in! 🚀"
        bottomLabel.textAlignment = .center
        bottomLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        bottomLabel.textColor = .systemTeal
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false

        // Main vertical stack
        let stack = UIStackView(arrangedSubviews: [
            iconView, titleLabel, descLabel, emailField, sendButton, cancelButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(10, after: iconView)
        stack.setCustomSpacing(7, after: titleLabel)
        stack.setCustomSpacing(14, after: descLabel)
        stack.setCustomSpacing(20, after: emailField)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(bottomLabel)
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 54),
            iconView.widthAnchor.constraint(equalToConstant: 54),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            // leave space for bottom message and wave
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -90),

            bottomLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            bottomLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            bottomLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIconBounceAndWiggle()
        animateSheetEntrance()
    }

    func addBottomWave() {
        // Draw a wavy shape for the bottom
        let waveHeight: CGFloat = 64
        let wavePath = UIBezierPath()
        let width = view.bounds.width
        let height = view.bounds.height
        wavePath.move(to: CGPoint(x: 0, y: height - waveHeight))
        wavePath.addCurve(
            to: CGPoint(x: width, y: height - waveHeight),
            controlPoint1: CGPoint(x: width * 0.25, y: height - waveHeight - 28),
            controlPoint2: CGPoint(x: width * 0.75, y: height - waveHeight + 28)
        )
        wavePath.addLine(to: CGPoint(x: width, y: height))
        wavePath.addLine(to: CGPoint(x: 0, y: height))
        wavePath.close()

        waveLayer.path = wavePath.cgPath
        waveLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.13).cgColor
        view.layer.insertSublayer(waveLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Redraw wave on rotation
        waveLayer.frame = view.bounds
        addBottomWave()
    }

    @objc func sendTapped() {
        guard let email = emailField.text, !email.isEmpty else {
            shake(view: emailField)
            return
        }
        // Animate button
        UIView.animate(withDuration: 0.07, animations: { self.sendButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) }) { _ in
            UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [], animations: {
                self.sendButton.transform = .identity
            }, completion: nil)
        }
        onSend?(email)
        dismiss(animated: true)
    }

    @objc func cancelTapped() { dismiss(animated: true) }

    func shake(view: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.4
        anim.values = [-8, 8, -6, 6, -4, 4, 0]
        view.layer.add(anim, forKey: "shake")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func animateIconBounceAndWiggle() {
        iconView.transform = CGAffineTransform(translationX: 0, y: -30).scaledBy(x: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.55,
                       initialSpringVelocity: 0.4,
                       options: [],
                       animations: {
            self.iconView.transform = .identity
        }, completion: { _ in
            // Wiggle
            UIView.animate(withDuration: 0.12, animations: {
                self.iconView.transform = CGAffineTransform(rotationAngle: .pi / 14)
            }) { _ in
                UIView.animate(withDuration: 0.12) {
                    self.iconView.transform = .identity
                }
            }
        })
    }

    func animateSheetEntrance() {
        view.transform = CGAffineTransform(translationX: 0, y: 80)
        view.alpha = 0.85
        UIView.animate(withDuration: 0.44,
                       delay: 0,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.6,
                       options: [],
                       animations: {
            self.view.transform = .identity
            self.view.alpha = 1
        }, completion: nil)
    }

    /// Configures the text field to look like the rectangular fields on your signup/login screens.
    func configureRectangularTextField(_ field: UITextField, placeholder: String) {
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.90)
        field.layer.cornerRadius = 11
        field.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        field.textColor = .label
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        field.leftViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
}
