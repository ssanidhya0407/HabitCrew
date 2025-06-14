import UIKit

struct OnboardingPage {
    let systemImageName: String
    let accentColor: UIColor
    let title: String
    let description: String
}

class OnboardingViewController: UIViewController, UIScrollViewDelegate {

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImageName: "person.3.sequence.fill",
            accentColor: .systemBlue,
            title: "Build Habits Together",
            description: "Set shared goals with friends. Motivate and support each other for lasting personal growth."
        ),
        OnboardingPage(
            systemImageName: "hand.raised.fill",
            accentColor: .systemGreen,
            title: "Accountability, Effortlessly",
            description: "Stay on track with real-time progress, gentle reminders, and a supportive crew."
        ),
        OnboardingPage(
            systemImageName: "sparkles",
            accentColor: .systemPurple,
            title: "Celebrate Every Win",
            description: "Cheer each other on, share encouragement, and make habit building fun."
        )
    ]

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let pageControl = UIPageControl()
    private let getStartedButton = UIButton(type: .system)
    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
        setupScrollView()
        setupPages()
        setupPageControl()
        setupGetStartedButton()
        addBrandNameLogo()
    }

    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.96, green: 0.92, blue: 1.0, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.15, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupDecorativeBlobs() {
        let topBlob = UIView()
        topBlob.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
        topBlob.layer.cornerRadius = 120
        topBlob.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(topBlob, aboveSubview: view)
        NSLayoutConstraint.activate([
            topBlob.widthAnchor.constraint(equalToConstant: 220),
            topBlob.heightAnchor.constraint(equalToConstant: 220),
            topBlob.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -70),
            topBlob.topAnchor.constraint(equalTo: view.topAnchor, constant: -50)
        ])

        let bottomBlob = UIView()
        bottomBlob.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.09)
        bottomBlob.layer.cornerRadius = 120
        bottomBlob.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(bottomBlob, aboveSubview: view)
        NSLayoutConstraint.activate([
            bottomBlob.widthAnchor.constraint(equalToConstant: 220),
            bottomBlob.heightAnchor.constraint(equalToConstant: 220),
            bottomBlob.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 70),
            bottomBlob.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 70)
        ])
    }

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

    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    private func setupPages() {
        for page in pages {
            let pageView = UIView()
            pageView.backgroundColor = .clear

            // Card - Hug content and be centered
            let cardView = UIView()
            cardView.layer.cornerRadius = 38
            cardView.layer.masksToBounds = true
            cardView.translatesAutoresizingMaskIntoConstraints = false

            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
            blur.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(blur)
            NSLayoutConstraint.activate([
                blur.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
                blur.topAnchor.constraint(equalTo: cardView.topAnchor),
                blur.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
            ])

            cardView.layer.shadowColor = page.accentColor.cgColor
            cardView.layer.shadowRadius = 36
            cardView.layer.shadowOpacity = 0.10
            cardView.layer.shadowOffset = CGSize(width: 0, height: 8)

            // RING + ICON stack
            let ring = UIView()
            ring.translatesAutoresizingMaskIntoConstraints = false
            ring.backgroundColor = UIColor.clear
            ring.layer.cornerRadius = 80
            ring.layer.borderWidth = 8
            ring.layer.borderColor = page.accentColor.withAlphaComponent(0.14).cgColor

            let imageConfig = UIImage.SymbolConfiguration(pointSize: 90, weight: .bold, scale: .large)
            let imageView = UIImageView(image: UIImage(systemName: page.systemImageName, withConfiguration: imageConfig))
            imageView.tintColor = page.accentColor
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.shadowColor = page.accentColor.withAlphaComponent(0.18).cgColor
            imageView.layer.shadowRadius = 16
            imageView.layer.shadowOpacity = 0.14
            imageView.layer.shadowOffset = CGSize(width: 0, height: 8)

            let iconContainer = UIView()
            iconContainer.translatesAutoresizingMaskIntoConstraints = false
            iconContainer.addSubview(ring)
            iconContainer.addSubview(imageView)

            NSLayoutConstraint.activate([
                ring.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                ring.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                ring.widthAnchor.constraint(equalToConstant: 160),
                ring.heightAnchor.constraint(equalToConstant: 160),

                imageView.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 90),
                imageView.heightAnchor.constraint(equalToConstant: 90),

                iconContainer.heightAnchor.constraint(equalToConstant: 160),
                iconContainer.widthAnchor.constraint(equalToConstant: 160)
            ])

            // Divider
            let divider = UIView()
            divider.backgroundColor = page.accentColor.withAlphaComponent(0.13)
            divider.layer.cornerRadius = 2
            divider.translatesAutoresizingMaskIntoConstraints = false
            divider.heightAnchor.constraint(equalToConstant: 4).isActive = true
            divider.widthAnchor.constraint(equalToConstant: 44).isActive = true

            // Title
            let titleLabel = UILabel()
            titleLabel.text = page.title
            titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            titleLabel.textAlignment = .center
            titleLabel.textColor = .label
            titleLabel.numberOfLines = 2
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            // Description
            let descLabel = UILabel()
            descLabel.text = page.description
            descLabel.font = UIFont.systemFont(ofSize: 18.5, weight: .regular)
            descLabel.textAlignment = .center
            descLabel.numberOfLines = 3
            descLabel.textColor = .secondaryLabel
            descLabel.translatesAutoresizingMaskIntoConstraints = false

            // Center stack - with vertical padding inside the card
            let contentStack = UIStackView(arrangedSubviews: [iconContainer, divider, titleLabel, descLabel])
            contentStack.axis = .vertical
            contentStack.alignment = .center
            contentStack.spacing = 22
            contentStack.setCustomSpacing(14, after: iconContainer)
            contentStack.setCustomSpacing(14, after: divider)
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(contentStack)

            // Card constraints: Centered, hug content, with min and max width for adaptability
            pageView.addSubview(cardView)
            NSLayoutConstraint.activate([
                cardView.centerYAnchor.constraint(equalTo: pageView.centerYAnchor),
                cardView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
                cardView.widthAnchor.constraint(lessThanOrEqualTo: pageView.widthAnchor, multiplier: 0.92),
                cardView.widthAnchor.constraint(greaterThanOrEqualToConstant: 320),
                cardView.leadingAnchor.constraint(greaterThanOrEqualTo: pageView.leadingAnchor, constant: 16),
                cardView.trailingAnchor.constraint(lessThanOrEqualTo: pageView.trailingAnchor, constant: -16),
            ])
            // Content stack: vertical padding
            NSLayoutConstraint.activate([
                contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
                contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28),
                contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 26),
                contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -26),
            ])

            stackView.addArrangedSubview(pageView)
            pageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.11)
        pageControl.currentPageIndicatorTintColor = UIColor.systemBlue.withAlphaComponent(0.55)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -85),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupGetStartedButton() {
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        getStartedButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.16)
        getStartedButton.setTitleColor(.systemBlue, for: .normal)
        getStartedButton.layer.cornerRadius = 14
        getStartedButton.alpha = 0 // Hidden initially
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        getStartedButton.addTarget(self, action: #selector(didTapGetStarted), for: .touchUpInside)
        view.addSubview(getStartedButton)

        NSLayoutConstraint.activate([
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = pageIndex
        UIView.animate(withDuration: 0.22) {
            self.getStartedButton.alpha = (pageIndex == self.pages.count - 1) ? 1 : 0
        }
    }

    @objc private func didTapGetStarted() {
        // Replace this with your Welcome/Login/SignUp screen navigation
        let welcomeVC = WelcomeViewController()
        welcomeVC.modalPresentationStyle = .fullScreen
        present(welcomeVC, animated: true)
    }
}
