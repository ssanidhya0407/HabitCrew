import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController {
    // MARK: - Model
    struct SignupForm {
        var name: String = ""
        var email: String = ""
        var password: String = ""
    }
    private let gradientLayer = CAGradientLayer()
    private var form = SignupForm()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        addBrandNameLogo()
        setupCard()
        setupBackButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Gradient & Blobs
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
        let topBlob = UIView()
        topBlob.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        topBlob.layer.cornerRadius = 100
        topBlob.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBlob)
        NSLayoutConstraint.activate([
            topBlob.widthAnchor.constraint(equalToConstant: 190),
            topBlob.heightAnchor.constraint(equalToConstant: 190),
            topBlob.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -48),
            topBlob.topAnchor.constraint(equalTo: view.topAnchor, constant: -48)
        ])

        let bottomBlob = UIView()
        bottomBlob.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.07)
        bottomBlob.layer.cornerRadius = 100
        bottomBlob.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBlob)
        NSLayoutConstraint.activate([
            bottomBlob.widthAnchor.constraint(equalToConstant: 190),
            bottomBlob.heightAnchor.constraint(equalToConstant: 190),
            bottomBlob.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 48),
            bottomBlob.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 48)
        ])
    }

    // MARK: - Branding
    private func addBrandNameLogo() {
        let logoStack = UIStackView()
        logoStack.axis = .horizontal
        logoStack.alignment = .center
        logoStack.spacing = 8
        logoStack.translatesAutoresizingMaskIntoConstraints = false

        let logoView = UIImageView(image: UIImage(systemName: "circle.grid.3x3.fill"))
        logoView.tintColor = UIColor.systemBlue.withAlphaComponent(0.83)
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.widthAnchor.constraint(equalToConstant: 26).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 26).isActive = true

        let brandLabel = UILabel()
        brandLabel.text = "HabitCrew"
        brandLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        brandLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.90)
        brandLabel.translatesAutoresizingMaskIntoConstraints = false

        logoStack.addArrangedSubview(logoView)
        logoStack.addArrangedSubview(brandLabel)
        view.addSubview(logoStack)
        NSLayoutConstraint.activate([
            logoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18)
        ])
    }

    // MARK: - Card Setup
    private func setupCard() {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 34
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .clear
        cardView.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.11).cgColor
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowRadius = 28
        cardView.layer.shadowOffset = CGSize(width: 0, height: 7)

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        // Icon & ring
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        let ring = UIView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.backgroundColor = UIColor.clear
        ring.layer.cornerRadius = 52
        ring.layer.borderWidth = 6
        ring.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        iconContainer.addSubview(ring)

        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .bold, scale: .large)
        let icon = UIImageView(image: UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: config))
        icon.tintColor = .systemBlue
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.18).cgColor
        icon.layer.shadowRadius = 8
        icon.layer.shadowOpacity = 0.13
        icon.layer.shadowOffset = CGSize(width: 0, height: 2)
        iconContainer.addSubview(icon)

        NSLayoutConstraint.activate([
            ring.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            ring.widthAnchor.constraint(equalToConstant: 104),
            ring.heightAnchor.constraint(equalToConstant: 104),

            icon.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 56),
            icon.heightAnchor.constraint(equalToConstant: 56),

            iconContainer.heightAnchor.constraint(equalToConstant: 104),
            iconContainer.widthAnchor.constraint(equalToConstant: 104)
        ])

        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.13)
        divider.layer.cornerRadius = 2
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 3.5).isActive = true
        divider.widthAnchor.constraint(equalToConstant: 32).isActive = true

        // Title & Description
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Create your account"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label

        let descLabel = UILabel()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.text = "Sign up to join HabitCrew and start your journey with friends."
        descLabel.font = UIFont.systemFont(ofSize: 16.5, weight: .regular)
        descLabel.textAlignment = .center
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0

        // Fields (rectangular, bigger)
        let nameField = makeField(placeholder: "Name")
        nameField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)

        let emailField = makeField(placeholder: "Email", keyboardType: .emailAddress)
        emailField.addTarget(self, action: #selector(emailChanged(_:)), for: .editingChanged)

        let passwordField = makeField(placeholder: "Password", isSecure: true)
        passwordField.addTarget(self, action: #selector(passwordChanged(_:)), for: .editingChanged)

        // Sign Up Button
        let signupButton = UIButton(type: .system)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        signupButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
        signupButton.setTitleColor(.systemBlue, for: .normal)
        signupButton.layer.cornerRadius = 12
        signupButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)

        // Error label
        let errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .systemRed
        errorLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.tag = 9001

        // Stack for content
        let contentStack = UIStackView(arrangedSubviews: [
            iconContainer,
            divider,
            titleLabel,
            descLabel,
            nameField,
            emailField,
            passwordField,
            signupButton,
            errorLabel
        ])
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 18
        contentStack.setCustomSpacing(12, after: iconContainer)
        contentStack.setCustomSpacing(8, after: divider)
        contentStack.setCustomSpacing(15, after: descLabel)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 34),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 28),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -28),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -34)
        ])

        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            cardView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.95),
            cardView.widthAnchor.constraint(greaterThanOrEqualToConstant: 340),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
        ])
    }

    private func makeField(placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) -> UITextField {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.90)
        field.layer.cornerRadius = 11
        field.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        field.textColor = .label
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = keyboardType
        field.isSecureTextEntry = isSecure
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        field.leftViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return field
    }

    // MARK: - Field Change Handlers
    @objc private func nameChanged(_ sender: UITextField) {
        form.name = sender.text ?? ""
    }
    @objc private func emailChanged(_ sender: UITextField) {
        form.email = sender.text ?? ""
    }
    @objc private func passwordChanged(_ sender: UITextField) {
        form.password = sender.text ?? ""
    }

    // MARK: - Signup Action
    @objc private func signupTapped() {
        view.endEditing(true)

        guard !form.name.isEmpty, !form.email.isEmpty, !form.password.isEmpty else {
            showError("Please fill in all fields.")
            return
        }
        guard form.password.count >= 6 else {
            showError("Password must be at least 6 characters.")
            return
        }

        Auth.auth().createUser(withEmail: form.email, password: form.password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            guard let user = result?.user else {
                self.showError("Failed to register user.")
                return
            }
            // Set display name for Firebase Auth user
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = self.form.name
            changeRequest.commitChanges(completion: nil)

            // Save extra user data to Firestore (users/uid)
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "uid": user.uid,
                "name": self.form.name,
                "email": self.form.email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            db.collection("users").document(user.uid).setData(userData) { err in
                if let err = err {
                    self.showError("Failed to save user data: \(err.localizedDescription)")
                    return
                }
                // Show green splash
                let splash = GreenSplashViewController()
                splash.modalPresentationStyle = .fullScreen
                self.present(splash, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        self.dismiss(animated: false)
                    }
                }
            }
        }
    }

    private func showError(_ message: String) {
        if let errorLabel = view.viewWithTag(9001) as? UILabel {
            errorLabel.text = message
            errorLabel.isHidden = false
        }
    }

    // MARK: - Back Button
    private func setupBackButton() {
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        close.tintColor = .systemBlue
        close.translatesAutoresizingMaskIntoConstraints = false
        close.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        close.layer.cornerRadius = 17
        close.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        close.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        view.addSubview(close)
        NSLayoutConstraint.activate([
            close.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            close.widthAnchor.constraint(equalToConstant: 34),
            close.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
