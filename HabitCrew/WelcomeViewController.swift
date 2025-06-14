import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

class WelcomeViewController: UIViewController {

    private let gradientLayer = CAGradientLayer()

    // MARK: - Brand
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

    // MARK: - Card
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 34
        v.layer.masksToBounds = true
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.11).cgColor
        v.layer.shadowOpacity = 1.0
        v.layer.shadowRadius = 28
        v.layer.shadowOffset = CGSize(width: 0, height: 7)
        return v
    }()

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private let ring: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.layer.cornerRadius = 60
        v.layer.borderWidth = 6
        v.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.10).cgColor
        return v
    }()

    private let icon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .bold, scale: .large)
        let img = UIImage(systemName: "hand.wave.fill", withConfiguration: config)
        let iv = UIImageView(image: img)
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.20).cgColor
        iv.layer.shadowRadius = 8
        iv.layer.shadowOpacity = 0.15
        iv.layer.shadowOffset = CGSize(width: 0, height: 3)
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to\nHabitCrew"
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Build habits, stay accountable, and\ncelebrate together with your friends."
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Buttons

    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }()

    private let appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 14
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Already have an account?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.backgroundColor = .clear
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        addBrandNameLogo()
        setupCard()
        setupButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Card Setup
    private func setupCard() {
        view.addSubview(cardView)
        cardView.addSubview(blurView)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            cardView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.91),
            cardView.widthAnchor.constraint(greaterThanOrEqualToConstant: 320),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 14),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -14),
        ])
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: cardView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        iconContainer.addSubview(ring)
        iconContainer.addSubview(icon)
        NSLayoutConstraint.activate([
            ring.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            ring.widthAnchor.constraint(equalToConstant: 120),
            ring.heightAnchor.constraint(equalToConstant: 120),

            icon.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 72),
            icon.heightAnchor.constraint(equalToConstant: 72),

            iconContainer.heightAnchor.constraint(equalToConstant: 120),
            iconContainer.widthAnchor.constraint(equalToConstant: 120)
        ])

        let divider = UIView()
        divider.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        divider.layer.cornerRadius = 2
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 3.5).isActive = true
        divider.widthAnchor.constraint(equalToConstant: 36).isActive = true

        let contentStack = UIStackView(arrangedSubviews: [iconContainer, divider, titleLabel, descLabel])
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 18
        contentStack.setCustomSpacing(10, after: iconContainer)
        contentStack.setCustomSpacing(10, after: divider)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 26),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 26),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -26),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -26)
        ])
    }

    // MARK: - Buttons
    private func setupButtons() {
        let buttonStack = UIStackView(arrangedSubviews: [signupButton, appleButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)

        // "Already have an account?" as a link below
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 38),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            loginButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 14),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        signupButton.addTarget(self, action: #selector(didTapSignup), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)
    }

    @objc private func didTapSignup() {
        let signupVC = SignupViewController()
        signupVC.modalPresentationStyle = .fullScreen
        present(signupVC, animated: true)
    }

    @objc private func didTapLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }

    @objc private func didTapAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension WelcomeViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: "")

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    let alert = UIAlertController(title: "Apple Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                guard let user = authResult?.user else { return }

                // Prepare Firestore user data
                let uid = user.uid
                let email = user.email ?? (appleIDCredential.email ?? "")
                let name: String
                if let fullName = appleIDCredential.fullName {
                    let given = fullName.givenName ?? ""
                    let family = fullName.familyName ?? ""
                    name = ([given, family].filter { !$0.isEmpty }).joined(separator: " ")
                } else {
                    name = user.displayName ?? ""
                }

                // Create/update user document in Firestore
                let db = Firestore.firestore()
                let userDoc: [String: Any] = [
                    "uid": uid,
                    "email": email,
                    "name": name
                ]
                db.collection("users").document(uid).setData(userDoc, merge: true) { err in
                    if let err = err {
                        print("Error writing user to Firestore: \(err)")
                    } else {
                        print("User added/updated in Firestore")
                    }
                }
 
                let tabBar = MainTabBarController()
                tabBar.modalPresentationStyle = .fullScreen
                self.present(tabBar, animated: true, completion: nil)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "Apple Login Failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
