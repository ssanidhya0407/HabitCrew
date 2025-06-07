import UIKit

class AddHabitViewController: UIViewController {
    // MARK: - UI Elements
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let cardView = UIView()
    private let promptLabel = UILabel()
    private let activityStack = UIStackView()
    private var activityButtons: [UIButton] = []
    private let timesStepper = HabitStepper()
    private let daysStepper = HabitStepper()
    private let pageControl = UIPageControl()
    private let nextButton = UIButton(type: .system)
    private let activities = ["Activity", "Meditate", "Workout"]
    private var selectedActivityIdx = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        overrideUserInterfaceStyle = .light
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#D5FFF3")
        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(hex: "#D5FFF3")
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 110)
        ])

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.text = "Create"
        titleLabel.textColor = .black
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18)
        ])

        // Close
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        headerView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 40
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Prompt
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.text = "I want to"
        promptLabel.font = UIFont.boldSystemFont(ofSize: 32)
        promptLabel.textColor = .black
        cardView.addSubview(promptLabel)
        NSLayoutConstraint.activate([
            promptLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            promptLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32)
        ])

        // Activities
        activityStack.translatesAutoresizingMaskIntoConstraints = false
        activityStack.axis = .horizontal
        activityStack.spacing = 18
        cardView.addSubview(activityStack)
        NSLayoutConstraint.activate([
            activityStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            activityStack.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 28),
            activityStack.heightAnchor.constraint(equalToConstant: 52)
        ])
        for (i, name) in activities.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(name, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            btn.layer.cornerRadius = 18
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 22, bottom: 8, right: 22)
            btn.addTarget(self, action: #selector(activitySelected(_:)), for: .touchUpInside)
            btn.tag = i
            btn.setTitleColor(.black, for: .normal)
            btn.backgroundColor = (i == selectedActivityIdx) ? UIColor(hex: "#D5FFF3") : UIColor(white: 0, alpha: 0.08)
            btn.layer.borderWidth = (i == selectedActivityIdx) ? 3 : 0
            btn.layer.borderColor = (i == selectedActivityIdx) ? UIColor(hex: "#D5FFF3")!.cgColor : UIColor.clear.cgColor
            activityStack.addArrangedSubview(btn)
            activityButtons.append(btn)
        }

        // Times Stepper
        timesStepper.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(timesStepper)
        NSLayoutConstraint.activate([
            timesStepper.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            timesStepper.topAnchor.constraint(equalTo: activityStack.bottomAnchor, constant: 44),
            timesStepper.widthAnchor.constraint(equalToConstant: 120),
            timesStepper.heightAnchor.constraint(equalToConstant: 52)
        ])
        timesStepper.label.text = "times in"
        timesStepper.label.textColor = .black
        timesStepper.valueLabel.textColor = .black
        timesStepper.backgroundColor = UIColor(white: 0, alpha: 0.07)

        // Days Stepper
        daysStepper.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(daysStepper)
        NSLayoutConstraint.activate([
            daysStepper.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            daysStepper.topAnchor.constraint(equalTo: timesStepper.bottomAnchor, constant: 24),
            daysStepper.widthAnchor.constraint(equalToConstant: 120),
            daysStepper.heightAnchor.constraint(equalToConstant: 52)
        ])
        daysStepper.label.text = "days."
        daysStepper.label.textColor = .black
        daysStepper.valueLabel.textColor = .black
        daysStepper.backgroundColor = UIColor(white: 0, alpha: 0.07)

        // PageControl
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(white: 0, alpha: 0.1)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "#D5FFF3")
        cardView.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: daysStepper.bottomAnchor, constant: 32)
        ])

        // Next Button
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.backgroundColor = UIColor(hex: "#D5FFF3")
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.layer.cornerRadius = 28
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        cardView.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            nextButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 32),
            nextButton.widthAnchor.constraint(equalToConstant: 160),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc private func activitySelected(_ sender: UIButton) {
        for btn in activityButtons {
            btn.backgroundColor = (btn == sender) ? UIColor(hex: "#D5FFF3") : UIColor(white: 0, alpha: 0.08)
            btn.layer.borderWidth = btn == sender ? 3 : 0
            btn.layer.borderColor = btn == sender ? UIColor(hex: "#D5FFF3")!.cgColor : UIColor.clear.cgColor
        }
        selectedActivityIdx = sender.tag
    }
    @objc private func closeTapped() { dismiss(animated: true) }
    @objc private func nextTapped() {
        // Use your current backend logic to create the habit here
    }
}

class HabitStepper: UIView {
    let label = UILabel()
    let valueLabel = UILabel()
    var value: Int = 1 {
        didSet { valueLabel.text = "\(value)" }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.07)
        layer.cornerRadius = 14
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        addSubview(label)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 22)
        valueLabel.textColor = .black
        valueLabel.text = "\(value)"
        addSubview(valueLabel)
        let up = UIButton(type: .system)
        up.setTitle("▲", for: .normal)
        up.tintColor = .black
        up.addTarget(self, action: #selector(increment), for: .touchUpInside)
        up.translatesAutoresizingMaskIntoConstraints = false
        addSubview(up)
        let down = UIButton(type: .system)
        down.setTitle("▼", for: .normal)
        down.tintColor = .black
        down.addTarget(self, action: #selector(decrement), for: .touchUpInside)
        down.translatesAutoresizingMaskIntoConstraints = false
        addSubview(down)
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.widthAnchor.constraint(equalToConstant: 28),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 10),
            up.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            up.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            down.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            down.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    @objc private func increment() { value += 1 }
    @objc private func decrement() { if value > 1 { value -= 1 } }
}

