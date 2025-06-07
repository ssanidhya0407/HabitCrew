//import UIKit
//
//class TasksViewController: UIViewController {
//
//    // MARK: - UI Components
//    private let headerView = UIView()
//    private let titleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let searchButton = UIButton(type: .system)
//    private let moreButton = UIButton(type: .system)
//    private let filterSegmentedControl = UISegmentedControl(items: ["All", "Active", "Completed"])
//    private let tableView = UITableView()
//    private let emptyStateView = ModernEmptyStateView(message: "No habits yet. Tap + to get started!")
//    private let addButton = ModernFloatingActionButton()
//    
//    // Data
//    private var habits: [Habit] = []
//    private var filteredHabits: [Habit] = []
//    private var isLoading = true
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupTableView()
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        loadHabits()
//        updateDateLabel()
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Add shadow below header
//        headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        // Header
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.backgroundColor = UIColor(named: "AppGreen") ?? UIColor(red: 0.14, green: 0.55, blue: 0.49, alpha: 1)
//        headerView.layer.shadowColor = UIColor.black.cgColor
//        headerView.layer.shadowOpacity = 0.08
//        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        headerView.layer.shadowRadius = 8
//        view.addSubview(headerView)
//        
//        // Title
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        titleLabel.textColor = .white
//        titleLabel.text = "Tasks"
//        headerView.addSubview(titleLabel)
//        
//        // Date
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        dateLabel.textColor = .white.withAlphaComponent(0.9)
//        headerView.addSubview(dateLabel)
//        
//        // Search
//        searchButton.translatesAutoresizingMaskIntoConstraints = false
//        searchButton.tintColor = .white
//        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
//        searchButton.accessibilityLabel = "Search"
//        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
//        headerView.addSubview(searchButton)
//        
//        // More
//        moreButton.translatesAutoresizingMaskIntoConstraints = false
//        moreButton.tintColor = .white
//        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//        moreButton.accessibilityLabel = "More options"
//        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
//        headerView.addSubview(moreButton)
//        
//        // Segmented Control
//        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        filterSegmentedControl.selectedSegmentIndex = 0
//        filterSegmentedControl.backgroundColor = .systemBackground
//        filterSegmentedControl.selectedSegmentTintColor = UIColor(named: "AppGreen") ?? UIColor(red: 0.14, green: 0.55, blue: 0.49, alpha: 1)
//        filterSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
//        filterSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
//        filterSegmentedControl.layer.cornerRadius = 10
//        filterSegmentedControl.layer.masksToBounds = true
//        filterSegmentedControl.layer.shadowColor = UIColor.black.cgColor
//        filterSegmentedControl.layer.shadowOpacity = 0.08
//        filterSegmentedControl.layer.shadowOffset = CGSize(width: 0, height: 1)
//        filterSegmentedControl.layer.shadowRadius = 2
//        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
//        view.addSubview(filterSegmentedControl)
//        
//        // TableView
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = .clear
//        tableView.separatorStyle = .none
//        tableView.showsVerticalScrollIndicator = false
//        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
//        view.addSubview(tableView)
//        
//        // Empty State
//        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
//        emptyStateView.isHidden = true
//        view.addSubview(emptyStateView)
//        
//        // Add Button
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        addButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
//        view.addSubview(addButton)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            headerView.topAnchor.constraint(equalTo: view.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            headerView.heightAnchor.constraint(equalToConstant: 120),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//            
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
//            
//            moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -18),
//            moreButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//            moreButton.widthAnchor.constraint(equalToConstant: 28),
//            moreButton.heightAnchor.constraint(equalToConstant: 28),
//            
//            searchButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -14),
//            searchButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//            searchButton.widthAnchor.constraint(equalToConstant: 28),
//            searchButton.heightAnchor.constraint(equalToConstant: 28),
//            
//            filterSegmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
//            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
//            
//            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 8),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
//            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -40),
//            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
//            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
//            
//            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            addButton.widthAnchor.constraint(equalToConstant: 56),
//            addButton.heightAnchor.constraint(equalToConstant: 56),
//        ])
//    }
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(ModernTaskCardCell.self, forCellReuseIdentifier: "ModernTaskCardCell")
//    }
//    private func updateDateLabel() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE, MMMM d"
//        dateLabel.text = formatter.string(from: Date())
//    }
//    
//    // MARK: - Data
//    private func loadHabits() {
//        isLoading = true
//        tableView.reloadData()
//        HabitService.shared.getHabits { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let habits):
//                    self.habits = habits
//                    self.applyFilter()
//                case .failure(let error):
//                    self.showAlert(title: "Error", message: error.localizedDescription)
//                }
//            }
//        }
//    }
//    private func applyFilter() {
//        switch filterSegmentedControl.selectedSegmentIndex {
//            case 0: filteredHabits = habits
//            case 1: filteredHabits = habits.filter { !$0.isCompletedToday() }
//            case 2: filteredHabits = habits.filter { $0.isCompletedToday() }
//            default: filteredHabits = habits
//        }
//        // Active: not completed, Completed: completed
//        if filterSegmentedControl.selectedSegmentIndex == 0 {
//            filteredHabits.sort { !$0.isCompletedToday() && $1.isCompletedToday() }
//        }
//        emptyStateView.isHidden = !filteredHabits.isEmpty
//        tableView.reloadData()
//    }
//    
//    // MARK: - Actions
//    @objc private func filterChanged() { applyFilter() }
//    @objc private func addHabitTapped() {
//        UIView.animate(withDuration: 0.1, animations: {
//            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        }) { _ in
//            UIView.animate(withDuration: 0.1) {
//                self.addButton.transform = CGAffineTransform.identity
//            }
//        }
//        let addHabitVC = AddHabitViewController()
//        addHabitVC.delegate = self
//        let navController = UINavigationController(rootViewController: addHabitVC)
//        present(navController, animated: true)
//    }
//    @objc private func searchTapped() {
//        showAlert(title: "Search", message: "Search functionality coming soon!")
//    }
//    @objc private func moreTapped() {
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Sort by date", style: .default, handler: nil))
//        actionSheet.addAction(UIAlertAction(title: "Sort by streak", style: .default, handler: nil))
//        actionSheet.addAction(UIAlertAction(title: "Settings", style: .default, handler: nil))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(actionSheet, animated: true)
//    }
//    private func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alertController, animated: true)
//    }
//}
//
//// MARK: - TableView
//extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isLoading { return 5 }
//        return filteredHabits.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ModernTaskCardCell", for: indexPath) as? ModernTaskCardCell else {
//            return UITableViewCell()
//        }
//        if isLoading {
//            cell.configureSkeleton()
//            return cell
//        }
//        let habit = filteredHabits[indexPath.row]
//        cell.configure(with: habit)
//        cell.delegate = self
//        return cell
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 84
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let habit = filteredHabits[indexPath.row]
//        let habitDetailVC = HabitDetailViewController(habit: habit)
//        habitDetailVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(habitDetailVC, animated: true)
//    }
//}
//
//// MARK: - TaskHabitCellDelegate
//extension TasksViewController: TaskHabitCellDelegate {
//    func didTapCompleteButton(for habit: Habit) {
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//        HabitService.shared.completeHabit(habitId: habit.id) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self.loadHabits()
//                case .failure(let error):
//                    self.showAlert(title: "Error", message: error.localizedDescription)
//                }
//            }
//        }
//    }
//}
//extension TasksViewController: AddHabitViewControllerDelegate {
//    func didAddHabit() { loadHabits() }
//}
//
//// MARK: - Modern Task Card Cell
//class ModernTaskCardCell: UITableViewCell {
//    private let cardView = UIView()
//    private let iconView = UIView()
//    private let iconImageView = UIImageView()
//    private let titleLabel = UILabel()
//    private let progressBar = GradientProgressBar()
//    private let progressLabel = UILabel()
//    private let completeButton = UIButton(type: .system)
//    
//    private var habit: Habit?
//    weak var delegate: TaskHabitCellDelegate?
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    
//    private func setupUI() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        // Card
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        cardView.backgroundColor = .systemBackground
//        cardView.layer.cornerRadius = 18
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.06
//        cardView.layer.shadowRadius = 5
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        contentView.addSubview(cardView)
//        
//        // Icon
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.layer.cornerRadius = 24
//        iconView.layer.masksToBounds = true
//        cardView.addSubview(iconView)
//        
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.tintColor = .white
//        iconView.addSubview(iconImageView)
//        
//        // Title
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//        titleLabel.textColor = .label
//        cardView.addSubview(titleLabel)
//        
//        // Progress Bar
//        progressBar.translatesAutoresizingMaskIntoConstraints = false
//        cardView.addSubview(progressBar)
//        
//        // Progress Label
//        progressLabel.translatesAutoresizingMaskIntoConstraints = false
//        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
//        progressLabel.textAlignment = .center
//        progressLabel.textColor = .white
//        progressBar.addSubview(progressLabel)
//        
//        // Complete Button
//        completeButton.translatesAutoresizingMaskIntoConstraints = false
//        completeButton.accessibilityLabel = "Mark as complete"
//        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
//        cardView.addSubview(completeButton)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
//            
//            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//            iconView.widthAnchor.constraint(equalToConstant: 48),
//            iconView.heightAnchor.constraint(equalToConstant: 48),
//            
//            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
//            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 28),
//            iconImageView.heightAnchor.constraint(equalToConstant: 28),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
//            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
//            
//            progressBar.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
//            progressBar.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -16),
//            progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            progressBar.heightAnchor.constraint(equalToConstant: 18),
//            
//            progressLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
//            progressLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
//            progressLabel.topAnchor.constraint(equalTo: progressBar.topAnchor),
//            progressLabel.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
//            
//            completeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            completeButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//            completeButton.widthAnchor.constraint(equalToConstant: 40),
//            completeButton.heightAnchor.constraint(equalToConstant: 40),
//        ])
//    }
//    
//    func configure(with habit: Habit) {
//        self.habit = habit
//        iconView.backgroundColor = UIColor(hex: habit.color) ?? .systemGray2
//        iconImageView.image = UIImage(systemName: habit.icon)
//        titleLabel.text = habit.title
//        titleLabel.textColor = habit.isCompletedToday() ? .secondaryLabel : .label
//        
//        // Progress
//        let progress = habit.progress ?? 1
//        let total = habit.total ?? 1
//        let percent = min(Float(progress) / Float(max(total, 1)), 1.0)
//        progressLabel.text = "\(progress)/\(total)"
//        progressBar.setProgress(percent, animated: true)
//        progressBar.gradientColors = [
//            UIColor(hex: habit.color) ?? .systemTeal,
//            UIColor(hex: habit.color) ?? .systemTeal
//        ]
//        
//        // Completion
//        let isCompleted = habit.isCompletedToday()
//        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
//        let image = UIImage(systemName: isCompleted ? "checkmark.circle.fill" : "circle", withConfiguration: config)
//        completeButton.setImage(image, for: .normal)
//        completeButton.tintColor = isCompleted ? .systemGreen : .systemGray3
//        
//        // Accessibility
//        completeButton.accessibilityLabel = isCompleted ? "Completed" : "Mark as complete"
//        completeButton.isUserInteractionEnabled = !isCompleted
//        cardView.alpha = isCompleted ? 0.7 : 1.0
//    }
//    func configureSkeleton() {
//        iconView.backgroundColor = .systemGray5
//        iconImageView.image = nil
//        titleLabel.text = "— — —"
//        progressLabel.text = ""
//        progressBar.setProgress(0.8, animated: false)
//        progressBar.gradientColors = [.systemGray4, .systemGray5]
//        completeButton.setImage(nil, for: .normal)
//    }
//    @objc private func completeTapped() {
//        guard let habit = habit else { return }
//        // Animate checkmark
//        UIView.animate(withDuration: 0.1, animations: {
//            self.completeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        }) { _ in
//            UIView.animate(withDuration: 0.1) {
//                self.completeButton.transform = .identity
//            }
//        }
//        delegate?.didTapCompleteButton(for: habit)
//    }
//}
//
//// MARK: - Gradient Progress Bar
//class GradientProgressBar: UIView {
//    var gradientColors: [UIColor] = [.systemTeal, .systemGreen] {
//        didSet { setNeedsDisplay() }
//    }
//    private(set) var progress: Float = 0
//    private let barLayer = CAGradientLayer()
//    private let bgLayer = CALayer()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        bgLayer.backgroundColor = UIColor.systemGray5.cgColor
//        layer.addSublayer(bgLayer)
//        barLayer.startPoint = CGPoint(x: 0, y: 0.5)
//        barLayer.endPoint = CGPoint(x: 1, y: 0.5)
//        layer.addSublayer(barLayer)
//        layer.cornerRadius = 9
//        clipsToBounds = true
//    }
//    required init?(coder: NSCoder) { fatalError() }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        bgLayer.frame = bounds
//        let width = CGFloat(progress) * bounds.width
//        barLayer.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
//        barLayer.colors = gradientColors.map { $0.cgColor }
//    }
//    func setProgress(_ p: Float, animated: Bool) {
//        let newProgress = max(0, min(1, p))
//        if animated {
//            UIView.animate(withDuration: 0.35) {
//                self.progress = newProgress
//                self.setNeedsLayout()
//                self.layoutIfNeeded()
//            }
//        } else {
//            progress = newProgress
//            setNeedsLayout()
//        }
//    }
//}
//
//// MARK: - Modern Floating Button
//class ModernFloatingActionButton: UIButton {
//    override init(frame: CGRect) { super.init(frame: frame); setup() }
//    required init?(coder: NSCoder) { fatalError() }
//    private func setup() {
//        backgroundColor = UIColor(named: "AppGreen") ?? UIColor(red: 0.14, green: 0.55, blue: 0.49, alpha: 1)
//        tintColor = .white
//        layer.cornerRadius = 28
//        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
//        setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 3)
//        layer.shadowOpacity = 0.2
//        layer.shadowRadius = 4
//    }
//}
//
//// MARK: - Modern Empty State
//class ModernEmptyStateView: UIView {
//    private let container = UIView()
//    private let imageView = UIImageView()
//    private let label = UILabel()
//    init(message: String) {
//        super.init(frame: .zero)
//        setup(message: message)
//    }
//    required init?(coder: NSCoder) { fatalError() }
//    private func setup(message: String) {
//        container.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(container)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = UIColor(named: "AppGreen")?.withAlphaComponent(0.7) ?? UIColor(red: 0.14, green: 0.55, blue: 0.49, alpha: 0.6)
//        imageView.image = UIImage(systemName: "list.bullet.rectangle.portrait")
//        container.addSubview(imageView)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        label.text = message
//        label.numberOfLines = 0
//        container.addSubview(label)
//        NSLayoutConstraint.activate([
//            container.centerXAnchor.constraint(equalTo: centerXAnchor),
//            container.centerYAnchor.constraint(equalTo: centerYAnchor),
//            container.widthAnchor.constraint(equalTo: widthAnchor),
//            imageView.topAnchor.constraint(equalTo: container.topAnchor),
//            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            imageView.heightAnchor.constraint(equalToConstant: 80),
//            imageView.widthAnchor.constraint(equalToConstant: 80),
//            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
//            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
//            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
//            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
//        ])
//    }
//}
//
//// MARK: - Utility
//
