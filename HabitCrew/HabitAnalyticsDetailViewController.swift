import UIKit
import FirebaseAuth
import FirebaseFirestore

class HabitAnalyticsDetailViewController: UIViewController {

    private let analyticsHabit: AnalyticsHabit
    private var buddyNameLabel: UILabel?

    // Gradient background
    private let gradientLayer = CAGradientLayer()

    // For animation and info sheet
    private var daysRow: UIStackView?
    private var timeCard: UIView?
    private var statsStack: UIStackView?
    private var additionalStatsStack: UIStackView?
    private var motiCard: UIView?
    private var chartView: UIView?

    // MARK: - Init
    init(analyticsHabit: AnalyticsHabit) {
        self.analyticsHabit = analyticsHabit
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        animateStats()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

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

    private func setupUI() {
        // Heading
        let headingLabel = UILabel()
        headingLabel.text = "Habit Analytics"
        headingLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        headingLabel.textColor = .label
        headingLabel.textAlignment = .center
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headingLabel)
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            headingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Back button
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .systemBlue
        backButton.semanticContentAttribute = .forceLeftToRight
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: headingLabel.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            backButton.widthAnchor.constraint(equalToConstant: 70)
        ])

        // ScrollView to fit all analytics data
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // Main content container for scrollView
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let contentWidth = scrollView.widthAnchor
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: contentWidth)
        ])

        // The main card (glassmorphic) with proper padding
        let card = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        card.backgroundColor = UIColor.white.withAlphaComponent(0.38)
        card.layer.cornerRadius = 38
        card.clipsToBounds = true
        card.layer.masksToBounds = true
        card.layer.borderWidth = 0.4
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        // Main vertical stack with proper spacing
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 36),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -24)
        ])

        // -- Title --
        let titleLabel = UILabel()
        titleLabel.text = analyticsHabit.title
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        stack.addArrangedSubview(titleLabel)

        // -- Icon in colored bubble --
        let color = UIColor(named: analyticsHabit.colorHex) ?? .systemBlue
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.layer.cornerRadius = 44
        iconBg.backgroundColor = color.withAlphaComponent(0.18)
        let iconView = UIImageView(image: UIImage(systemName: analyticsHabit.icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 88),
            iconBg.heightAnchor.constraint(equalToConstant: 88),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor)
        ])
        stack.addArrangedSubview(iconBg)

        // -- Days row (like list) & animated --
        let daysRow = UIStackView()
        daysRow.axis = .horizontal
        daysRow.spacing = 7
        daysRow.alignment = .center
        let dayLetters = ["S","M","T","W","T","F","S"]
        let scheduledDays = analyticsHabit.scheduledDays ?? []
        for i in 0..<7 {
            let lbl = UILabel()
            lbl.text = dayLetters[i]
            lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            lbl.textAlignment = .center
            let isActive = scheduledDays.contains(i)
            lbl.textColor = isActive ? .black : UIColor(white: 0.7, alpha: 1) // Black text
            lbl.backgroundColor = isActive ? color : UIColor.systemGray5
            lbl.layer.cornerRadius = 17
            lbl.layer.masksToBounds = true
            lbl.widthAnchor.constraint(equalToConstant: 34).isActive = true
            lbl.heightAnchor.constraint(equalToConstant: 34).isActive = true
            lbl.alpha = 0
            daysRow.addArrangedSubview(lbl)
        }
        self.daysRow = daysRow
        stack.addArrangedSubview(daysRow)

        // -- Time card (glassmorphic, full width) --
        var timeCardView: UIView? = nil
        if let timeString = analyticsHabit.timeString {
            let timeCard = statCard(
                icon: "clock",
                color: color,
                text: timeString,
                fontSize: 24,
                glass: true,
                textColor: .black // Always readable
            )
            timeCard.alpha = 0
            self.timeCard = timeCard
            stack.addArrangedSubview(timeCard)
            timeCardView = timeCard
        }

        // -- Progress/Stats: stacked vertically, wide cards with info button --
        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.alignment = .fill
        statsStack.distribution = .equalSpacing
        statsStack.spacing = 14
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        let streak = analyticsHabit.currentStreak
        let completionRate = Int(analyticsHabit.completionRate * 100)
        let totalCompletions = analyticsHabit.completedDates.count

        let streakCard = statCard(icon: "flame", color: .systemOrange, text: "\(streak) day streak", glass: true, textColor: .black, infoType: .streak)
        let completionCard = statCard(icon: "chart.pie", color: .systemPurple, text: "\(completionRate)% completion", glass: true, textColor: .black, infoType: .completion)
        let doneCard = statCard(icon: "checkmark.circle", color: .systemGreen, text: "\(totalCompletions) completions", glass: true, textColor: .black, infoType: .done)

        statsStack.addArrangedSubview(streakCard)
        statsStack.addArrangedSubview(completionCard)
        statsStack.addArrangedSubview(doneCard)
        
        // Add last check-in if available
        if let lastCheckIn = analyticsHabit.lastCheckin {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let lastCheckInString = dateFormatter.string(from: lastCheckIn)
            let lastCheckInCard = statCard(icon: "calendar.badge.clock", color: .systemTeal, text: "Last: \(lastCheckInString)", glass: true, textColor: .black)
            statsStack.addArrangedSubview(lastCheckInCard)
        }
        
        statsStack.alpha = 0
        self.statsStack = statsStack
        stack.addArrangedSubview(statsStack)

        // -- Trend chart --
        let chartContainer = createTrendChart()
        chartContainer.alpha = 0
        chartView = chartContainer
        stack.addArrangedSubview(chartContainer)

        // -- Additional Analytics Cards --
        let additionalStatsStack = UIStackView()
        additionalStatsStack.axis = .vertical
        additionalStatsStack.alignment = .fill
        additionalStatsStack.distribution = .equalSpacing
        additionalStatsStack.spacing = 14
        additionalStatsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Weekly consistency card
        let weeklyConsistency = calculateWeeklyConsistency()
        let weeklyCard = statCard(
            icon: "calendar.day.timeline.left",
            color: .systemIndigo,
            text: "\(weeklyConsistency)% weekly consistency",
            glass: true,
            textColor: .black,
            infoType: .weekly
        )
        
        // Best day of week card
        let (bestDay, bestDayPercentage) = calculateBestDay()
        let bestDayCard = statCard(
            icon: "star.fill",
            color: .systemYellow,
            text: "Best day: \(bestDay) (\(bestDayPercentage)%)",
            glass: true,
            textColor: .black,
            infoType: .bestDay
        )
        
        // Longest gap card
        let (gapDays, gapDates) = calculateLongestGap()
        let gapCard = statCard(
            icon: "exclamationmark.triangle.fill",
            color: .systemRed,
            text: "Longest gap: \(gapDays) days",
            glass: true,
            textColor: .black,
            infoType: .longestGap
        )
        
        // Improvement trend card
        let improvementTrend = calculateImprovementTrend()
        let improvementIcon = improvementTrend >= 0 ? "arrow.up.right" : "arrow.down.right"
        let improvementColor: UIColor = improvementTrend >= 0 ? .systemGreen : .systemRed
        let improvementCard = statCard(
            icon: improvementIcon,
            color: improvementColor,
            text: "\(abs(improvementTrend))% \(improvementTrend >= 0 ? "improvement" : "decline")",
            glass: true,
            textColor: .black,
            infoType: .trend
        )
        
        additionalStatsStack.addArrangedSubview(weeklyCard)
        additionalStatsStack.addArrangedSubview(bestDayCard)
        additionalStatsStack.addArrangedSubview(gapCard)
        additionalStatsStack.addArrangedSubview(improvementCard)
        
        additionalStatsStack.alpha = 0
        self.additionalStatsStack = additionalStatsStack
        stack.addArrangedSubview(additionalStatsStack)

        // -- Created row at the bottom --
        let createdLabel = UILabel()
        if let lastDate = analyticsHabit.completedDates.max() {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            createdLabel.text = "Last completed: \(df.string(from: lastDate))"
        } else {
            createdLabel.text = "No completions yet"
        }
        createdLabel.font = .systemFont(ofSize: 16, weight: .regular)
        createdLabel.textColor = .tertiaryLabel
        createdLabel.textAlignment = .center
        createdLabel.translatesAutoresizingMaskIntoConstraints = false
        createdLabel.alpha = 0
        stack.addArrangedSubview(createdLabel)
        
        // Make sure there's enough space for all content
        NSLayoutConstraint.activate([
            // Ensure the content view has enough height for all content
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: stack.heightAnchor, constant: 80),
        ])
    }

    // MARK: - Analytics calculation methods
    
    private func calculateWeeklyConsistency() -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        // Look at the last 8 weeks
        var totalWeeks = 0
        var consistentWeeks = 0
        
        // Group dates by week
        var weekCompletions: [Int: Set<Int>] = [:]
        
        for date in analyticsHabit.completedDates {
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let dayOfWeek = calendar.component(.weekday, from: date)
            
            if weekCompletions[weekOfYear] == nil {
                weekCompletions[weekOfYear] = Set<Int>()
            }
            weekCompletions[weekOfYear]?.insert(dayOfWeek)
        }
        
        // Calculate how many weeks had at least 4 days completed
        for (_, days) in weekCompletions {
            totalWeeks += 1
            if days.count >= 4 { // Consider 4+ days as consistent
                consistentWeeks += 1
            }
        }
        
        // Avoid division by zero
        if totalWeeks == 0 {
            return 0
        }
        
        return Int((Double(consistentWeeks) / Double(totalWeeks)) * 100)
    }
    
    private func calculateBestDay() -> (String, Int) {
        let calendar = Calendar.current
        let weekdayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var dayCounts = [Int: Int]()
        
        // Count completions by day of week
        for date in analyticsHabit.completedDates {
            let weekday = calendar.component(.weekday, from: date) - 1 // 0-based index
            dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1
        }
        
        // Find the day with max completions
        guard let maxDay = dayCounts.max(by: { $0.value < $1.value }) else {
            return ("None", 0)
        }
        
        // Calculate percentage
        let total = dayCounts.values.reduce(0, +)
        let percentage = Int((Double(maxDay.value) / Double(total)) * 100)
        
        return (weekdayNames[maxDay.key], percentage)
    }
    
    private func calculateLongestGap() -> (Int, [Date]) {
        let sortedDates = analyticsHabit.completedDates.sorted()
        guard sortedDates.count > 1 else {
            return (0, [])
        }
        
        var longestGap = 0
        var gapStartDate = sortedDates[0]
        var gapEndDate = sortedDates[0]
        
        for i in 1..<sortedDates.count {
            let currentDate = sortedDates[i]
            let prevDate = sortedDates[i-1]
            let gap = Calendar.current.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
            
            if gap > longestGap {
                longestGap = gap
                gapStartDate = prevDate
                gapEndDate = currentDate
            }
        }
        
        return (longestGap, [gapStartDate, gapEndDate])
    }
    
    private func calculateImprovementTrend() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let sortedDates = analyticsHabit.completedDates.sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        // Calculate check-ins in the past 30 days
        let recentCutoff = calendar.date(byAdding: .day, value: -30, to: today)!
        let recentCheckIns = sortedDates.filter { $0 >= recentCutoff }.count
        
        // Calculate check-ins in the previous 30 days
        let previousCutoff = calendar.date(byAdding: .day, value: -60, to: today)!
        let previousCheckIns = sortedDates.filter { $0 >= previousCutoff && $0 < recentCutoff }.count
        
        // Avoid division by zero
        if previousCheckIns == 0 {
            return recentCheckIns > 0 ? 100 : 0
        }
        
        // Calculate percentage change
        let change = recentCheckIns - previousCheckIns
        return Int((Double(change) / Double(previousCheckIns)) * 100)
    }
    
    // MARK: - Custom UI components
    
    private func createTrendChart() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 68).isActive = true
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 18
        
        let titleLabel = UILabel()
        titleLabel.text = "Completion Trend"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        // Create chart area
        let chartArea = UIView()
        chartArea.translatesAutoresizingMaskIntoConstraints = false
        chartArea.backgroundColor = .clear
        containerView.addSubview(chartArea)
        
        NSLayoutConstraint.activate([
            chartArea.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartArea.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            chartArea.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            chartArea.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
        ])
        
        // Calculate weekly completion data
        let weeklyData = calculateWeeklyCompletionData()
        
        // Create chart visualization
        let barWidth: CGFloat = (chartArea.bounds.width == 0 ? 300 : chartArea.bounds.width) / CGFloat(weeklyData.count) * 0.7
        let spacing: CGFloat = (chartArea.bounds.width == 0 ? 300 : chartArea.bounds.width) / CGFloat(weeklyData.count) * 0.3 / 2
        let maxHeight: CGFloat = 140
        
        // Generate bars for each week
        for (index, (weekLabel, percentage)) in weeklyData.enumerated() {
            // Bar
            let barContainer = UIView()
            barContainer.translatesAutoresizingMaskIntoConstraints = false
            chartArea.addSubview(barContainer)
            
            let barHeight = maxHeight * CGFloat(percentage) / 100.0
            
            // Position the bar
            NSLayoutConstraint.activate([
                barContainer.leadingAnchor.constraint(equalTo: chartArea.leadingAnchor, constant: spacing + CGFloat(index) * (barWidth + spacing * 2)),
                barContainer.bottomAnchor.constraint(equalTo: chartArea.bottomAnchor, constant: -20),
                barContainer.widthAnchor.constraint(equalToConstant: barWidth),
                barContainer.heightAnchor.constraint(equalToConstant: maxHeight)
            ])
            
            // The actual colored bar
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
            bar.layer.cornerRadius = 6
            barContainer.addSubview(bar)
            
            // Place the bar at the bottom with appropriate height
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: barContainer.trailingAnchor),
                bar.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
                bar.heightAnchor.constraint(equalToConstant: barHeight)
            ])
            
            // Week label
            let label = UILabel()
            label.text = weekLabel
            label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            chartArea.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
                label.topAnchor.constraint(equalTo: barContainer.bottomAnchor, constant: 4),
            ])
        }
        
        return containerView
    }
    
    private func calculateWeeklyCompletionData() -> [(String, Double)] {
        let calendar = Calendar.current
        let today = Date()
        var result: [(String, Double)] = []
        
        // Get last 6 weeks
        for i in (0..<6).reversed() {
            guard let startDate = calendar.date(byAdding: .weekOfYear, value: -i, to: today),
                  let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
                continue
            }
            
            let weekStart = calendar.startOfDay(for: startDate)
            let weekEnd = calendar.startOfDay(for: endDate)
            
            // Get scheduled days in this week
            let scheduledDays = analyticsHabit.scheduledDays ?? []
            var scheduledDatesInWeek = 0
            var currentDate = weekStart
            
            while currentDate <= weekEnd {
                let weekday = (calendar.component(.weekday, from: currentDate) + 6) % 7 // Sunday=0
                if scheduledDays.contains(weekday) {
                    scheduledDatesInWeek += 1
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            // Count completed scheduled dates in this week
            var completedCount = 0
            for date in analyticsHabit.completedDates {
                if date >= weekStart && date <= weekEnd {
                    let weekday = (calendar.component(.weekday, from: date) + 6) % 7
                    if scheduledDays.contains(weekday) {
                        completedCount += 1
                    }
                }
            }
            
            // Calculate completion percentage
            let percentage = scheduledDatesInWeek > 0 ? Double(completedCount) / Double(scheduledDatesInWeek) * 100.0 : 0
            
            // Format week label
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let weekLabel = "\(formatter.string(from: weekStart))"
            
            result.append((weekLabel, percentage))
        }
        
        return result
    }
    
    private func createHeatmap() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 68).isActive = true
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 18
        
        // Create a 7x4 grid for the heatmap (days of week × weeks)
        let heatmapData = calculateHeatmapData()
        let cellSize: CGFloat = 18
        let cellSpacing: CGFloat = 4
        let totalWidth = cellSize * 7 + cellSpacing * 6
        let totalHeight = cellSize * 4 + cellSpacing * 3
        
        // Day labels (top row)
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        for (index, day) in days.enumerated() {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(label)
            
            let xPosition = (containerView.bounds.width - totalWidth) / 2 + CGFloat(index) * (cellSize + cellSpacing)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: xPosition + cellSize/2),
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                label.widthAnchor.constraint(equalToConstant: cellSize),
                label.heightAnchor.constraint(equalToConstant: cellSize)
            ])
        }
        
        // Heatmap cells
        for row in 0..<4 {
            for col in 0..<7 {
                let cellView = UIView()
                cellView.translatesAutoresizingMaskIntoConstraints = false
                cellView.layer.cornerRadius = 4
                
                let intensity = heatmapData[row][col]
                cellView.backgroundColor = intensityColor(intensity)
                
                containerView.addSubview(cellView)
                
                let xPosition = (containerView.bounds.width - totalWidth) / 2 + CGFloat(col) * (cellSize + cellSpacing)
                let yPosition = 40 + CGFloat(row) * (cellSize + cellSpacing)
                
                NSLayoutConstraint.activate([
                    cellView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: xPosition),
                    cellView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: yPosition),
                    cellView.widthAnchor.constraint(equalToConstant: cellSize),
                    cellView.heightAnchor.constraint(equalToConstant: cellSize)
                ])
            }
        }
        
        // Legend
        let legendView = UIView()
        legendView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(legendView)
        
        NSLayoutConstraint.activate([
            legendView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            legendView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            legendView.heightAnchor.constraint(equalToConstant: 24),
            legendView.widthAnchor.constraint(equalToConstant: 230)
        ])
        
        let legendItems = [0, 1, 2, 3, 4]
        let legendItemWidth: CGFloat = 40
        
        for (index, intensity) in legendItems.enumerated() {
            let itemView = UIView()
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.backgroundColor = intensityColor(intensity)
            itemView.layer.cornerRadius = 4
            legendView.addSubview(itemView)
            
            let label = UILabel()
            label.text = intensityLabel(intensity)
            label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            legendView.addSubview(label)
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: legendView.leadingAnchor, constant: CGFloat(index) * legendItemWidth),
                itemView.topAnchor.constraint(equalTo: legendView.topAnchor),
                itemView.widthAnchor.constraint(equalToConstant: 14),
                itemView.heightAnchor.constraint(equalToConstant: 14),
                
                label.centerXAnchor.constraint(equalTo: itemView.centerXAnchor),
                label.topAnchor.constraint(equalTo: itemView.bottomAnchor, constant: 4),
            ])
        }
        
        return containerView
    }
    
    private func calculateHeatmapData() -> [[Int]] {
        let calendar = Calendar.current
        var heatmap = Array(repeating: Array(repeating: 0, count: 7), count: 4)
        
        // Count completions per day of week for the past 4 weeks
        let today = Date()
        let weekStart = calendar.component(.weekday, from: today)
        let completedDates = analyticsHabit.completedDates
        
        for weekOffset in 0..<4 {
            for dayOffset in 0..<7 {
                // Calculate the date for this cell
                guard let date = calendar.date(byAdding: .day, value: -((weekOffset * 7) + dayOffset), to: today) else {
                    continue
                }
                
                // Check if this date was completed
                let dateWithoutTime = calendar.startOfDay(for: date)
                let completionsToday = completedDates.filter { calendar.isDate($0, inSameDayAs: dateWithoutTime) }
                
                // Assign intensity based on completions
                let dayOfWeek = (calendar.component(.weekday, from: date) + 5) % 7 // Adjust to 0-indexed and make Sunday = 0
                heatmap[weekOffset][dayOfWeek] = completionsToday.isEmpty ? 0 : min(completionsToday.count, 4) // Limit to 4 levels
            }
        }
        
        return heatmap
    }
    
    private func intensityColor(_ intensity: Int) -> UIColor {
        switch intensity {
        case 0:
            return UIColor.systemGray5
        case 1:
            return UIColor.systemBlue.withAlphaComponent(0.25)
        case 2:
            return UIColor.systemBlue.withAlphaComponent(0.5)
        case 3:
            return UIColor.systemBlue.withAlphaComponent(0.75)
        default:
            return UIColor.systemBlue
        }
    }
    
    private func intensityLabel(_ intensity: Int) -> String {
        switch intensity {
        case 0:
            return "0"
        case 1:
            return "1"
        case 2:
            return "2"
        case 3:
            return "3"
        default:
            return "4+"
        }
    }

    // MARK: - Animated appearance
    private func animateStats() {
        guard let daysRow = daysRow else { return }
        for (i, lbl) in daysRow.arrangedSubviews.enumerated() {
            UIView.animate(withDuration: 0.3, delay: 0.08*Double(i), options: .curveEaseOut, animations: {
                lbl.alpha = 1
                lbl.transform = .identity
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.44, delay: 0.44, options: .curveEaseOut, animations: {
            self.timeCard?.alpha = 1
            self.statsStack?.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.35, delay: 0.88, options: .curveEaseOut, animations: {
            self.chartView?.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.35, delay: 1.1, options: .curveEaseOut, animations: {
            self.additionalStatsStack?.alpha = 1
            
            // Animate any other UI elements
            for view in self.view.subviews {
                if view.alpha == 0 {
                    view.alpha = 1
                }
            }
        }, completion: nil)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Modern glassmorphic stat card (full width, readable) with optional info button
    enum StatInfoType { case streak, completion, done, weekly, bestDay, longestGap, trend, none }
    private func statCard(icon: String, color: UIColor, text: String, fontSize: CGFloat = 18, filled: Bool = false, glass: Bool = false, textColor: UIColor? = nil, infoType: StatInfoType = .none) -> UIView {
        let card: UIView
        if glass {
            let ve = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
            ve.backgroundColor = filled ? color.withAlphaComponent(0.22) : color.withAlphaComponent(0.17)
            ve.layer.cornerRadius = 18
            ve.clipsToBounds = true
            ve.layer.borderWidth = 0.5
            ve.layer.borderColor = color.withAlphaComponent(0.18).cgColor
            ve.translatesAutoresizingMaskIntoConstraints = false
            card = ve
            ve.heightAnchor.constraint(equalToConstant: 50).isActive = true
            ve.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 68).isActive = true
        } else {
            let v = UIView()
            v.backgroundColor = filled ? color.withAlphaComponent(0.17) : color.withAlphaComponent(0.12)
            v.layer.cornerRadius = 18
            v.translatesAutoresizingMaskIntoConstraints = false
            v.heightAnchor.constraint(equalToConstant: 50).isActive = true
            v.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 68).isActive = true
            card = v
        }

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: fontSize, weight: .semibold)
        lbl.textColor = textColor ?? (color.analyticsisLight ? .black : .white)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        lbl.lineBreakMode = .byTruncatingTail
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [img, lbl])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.distribution = .fill

        // Add info button if needed
        if infoType != .none {
            let infoBtn = UIButton(type: .system)
            infoBtn.setImage(UIImage(systemName: "info.circle"), for: .normal)
            infoBtn.tintColor = .gray
            infoBtn.translatesAutoresizingMaskIntoConstraints = false
            infoBtn.widthAnchor.constraint(equalToConstant: 24).isActive = true
            infoBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
            row.addArrangedSubview(infoBtn)
            infoBtn.addTarget(self, action: #selector(handleInfoButton(_:)), for: .touchUpInside)
            infoBtn.tag = infoTypeToTag(infoType)
        }

        row.translatesAutoresizingMaskIntoConstraints = false

        if let ve = card as? UIVisualEffectView {
            ve.contentView.addSubview(row)
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: ve.contentView.leadingAnchor, constant: 20),
                row.trailingAnchor.constraint(equalTo: ve.contentView.trailingAnchor, constant: -20),
                row.centerYAnchor.constraint(equalTo: ve.contentView.centerYAnchor)
            ])
        } else {
            card.addSubview(row)
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                row.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
        }
        // Make the card tappable for info sheet as well
        if infoType != .none {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
            card.tag = infoTypeToTag(infoType)
        }

        return card
    }
    
    private func infoTypeToTag(_ type: StatInfoType) -> Int {
        switch type {
        case .streak: return 1
        case .completion: return 2
        case .done: return 3
        case .weekly: return 4
        case .bestDay: return 5
        case .longestGap: return 6
        case .trend: return 7
        case .none: return 0
        }
    }

    // MARK: - Info Sheet logic
    @objc private func handleInfoButton(_ sender: UIButton) {
        showInfoSheet(for: sender.tag)
    }
    
    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        showInfoSheet(for: tag)
    }
    
    private func showInfoSheet(for tag: Int) {
        var title: String = ""
        var message: String = ""
        var dates: [String] = []
        var infoType: InfoSheetViewControllerAnalytics.StatType = .streak
        var accentColor: UIColor = .systemOrange

        switch tag {
        case 1: // Streak
            title = "Current Streak"
            message = "Your current streak is \(analyticsHabit.currentStreak) days. These are consecutive days you completed this habit."
            
            // Find dates for the current streak
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let sortedDates = analyticsHabit.completedDates.map { calendar.startOfDay(for: $0) }.sorted()
            var streakDates: [Date] = []
            
            // Simple algorithm to find most recent consecutive dates
            for i in 0..<analyticsHabit.currentStreak {
                if let date = calendar.date(byAdding: .day, value: -i, to: today),
                   sortedDates.contains(date) {
                    streakDates.append(date)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dates = streakDates.map { dateFormatter.string(from: $0) }
            infoType = .streak
            accentColor = .systemOrange
        
        case 2: // Completion Rate
            title = "Completion Rate"
            message = "Your completion rate is \(Int(analyticsHabit.completionRate * 100))%. This is calculated based on scheduled vs completed habits in the last 30 days."
            infoType = .completion
            accentColor = .systemPurple
            
        case 3: // Total Completions
            title = "Total Completions"
            message = "You've completed this habit \(analyticsHabit.completedDates.count) times. Here are the dates:"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dates = analyticsHabit.completedDates.map { dateFormatter.string(from: $0) }.sorted()
            infoType = .done
            accentColor = .systemGreen
            
        case 4: // Weekly Consistency
            title = "Weekly Consistency"
            message = "This shows the percentage of weeks where you completed your habit at least 4 days a week. Higher consistency leads to better habit formation."
            infoType = .weekly
            accentColor = .systemIndigo
            
        case 5: // Best Day
            title = "Best Performing Day"
            let (bestDay, percentage) = calculateBestDay()
            message = "You complete this habit most often on \(bestDay)s (\(percentage)% of your completions). Understanding your best days can help optimize your schedule."
            infoType = .bestDay
            accentColor = .systemYellow
            
        case 6: // Longest Gap
            title = "Longest Gap"
            let (days, gapDates) = calculateLongestGap()
            message = "Your longest gap between completions was \(days) days."
            
            if !gapDates.isEmpty && gapDates.count >= 2 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let startDate = dateFormatter.string(from: gapDates[0])
                let endDate = dateFormatter.string(from: gapDates[1])
                message += " From \(startDate) to \(endDate)."
            }
            
            infoType = .longestGap
            accentColor = .systemRed
            
        case 7: // Improvement Trend
            title = "Improvement Trend"
            let trend = calculateImprovementTrend()
            if trend >= 0 {
                message = "You've improved by \(trend)% compared to the previous 30 days. Keep up the good work!"
            } else {
                message = "There's been a \(abs(trend))% decline compared to the previous 30 days. Try to get back on track!"
            }
            infoType = .trend
            accentColor = trend >= 0 ? .systemGreen : .systemRed
            
        default: return
        }

        let vc = InfoSheetViewControllerAnalytics(title: title, message: message, dates: dates, statType: infoType, accentColor: accentColor)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                let baseHeight: CGFloat = 160
                let dateRows = CGFloat(max(1, (dates.count+2)/3))
                return baseHeight + dateRows*45
            })]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
}

// MARK: - Info Sheet View Controller (Analytics version)
class InfoSheetViewControllerAnalytics: UIViewController {
    private var titleStr: String = ""
    private var msg: String = ""
    private var dateStrings: [String] = []
    private var statType: StatType = .streak
    private var accentColor: UIColor = .systemYellow

    enum StatType {
        case streak, completion, done, weekly, bestDay, longestGap, trend
    }

    init(title: String, message: String, dates: [String], statType: StatType = .streak, accentColor: UIColor = .systemYellow) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .pageSheet
        self.titleStr = title
        self.msg = message
        self.dateStrings = dates
        self.statType = statType
        self.accentColor = accentColor
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        // --- Translucent Glass Background ---
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.layer.cornerRadius = 28
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blur, at: 0)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            blur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        // --- Soft shadow for polish ---
        blur.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        blur.layer.shadowOpacity = 1
        blur.layer.shadowOffset = CGSize(width: 0, height: 3)
        blur.layer.shadowRadius = 28

        // --- Gradient/Colored Accent Bar ---
        let accent = UIView()
        accent.translatesAutoresizingMaskIntoConstraints = false
        accent.layer.cornerRadius = 4
        accent.clipsToBounds = true
        accent.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.colors = accentBarColors()
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = CGRect(x: 0, y: 0, width: 108, height: 8)
        accent.layer.insertSublayer(gradient, at: 0)
        view.addSubview(accent)
        NSLayoutConstraint.activate([
            accent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accent.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            accent.widthAnchor.constraint(equalToConstant: 108),
            accent.heightAnchor.constraint(equalToConstant: 8)
        ])

        // --- Main Stack ---
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: accent.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        // --- Emoji/Icon ---
        let iconLabel = UILabel()
        iconLabel.text = statIcon()
        iconLabel.font = .systemFont(ofSize: 44)
        iconLabel.textAlignment = .center
        stack.addArrangedSubview(iconLabel)

        // --- Title ---
        let titleLabel = UILabel()
        titleLabel.text = titleStr
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        // --- Description ---
        let descLabel = UILabel()
        descLabel.text = msg
        descLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descLabel.textColor = .label
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        stack.addArrangedSubview(descLabel)

        // --- Chips Section ---
        if !dateStrings.isEmpty {
            let scrollView = UIScrollView()
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(scrollView)
            
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentView)
            
            NSLayoutConstraint.activate([
                scrollView.heightAnchor.constraint(equalToConstant: 200),
                scrollView.widthAnchor.constraint(equalTo: stack.widthAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            // Flexible grid layout for date chips
            let chipWidth: CGFloat = 110
            let chipHeight: CGFloat = 40
            let horizontalSpacing: CGFloat = 8
            let verticalSpacing: CGFloat = 8
            let chipsPerRow = max(2, Int((scrollView.bounds.width - 20) / (chipWidth + horizontalSpacing)))
            
            var currentX: CGFloat = 0
            var currentY: CGFloat = 10
            
            for (i, dateStr) in dateStrings.enumerated() {
                let chip = UILabel()
                chip.text = dateStr
                chip.font = .systemFont(ofSize: 15, weight: .semibold)
                chip.textAlignment = .center
                chip.backgroundColor = .white.withAlphaComponent(0.95)
                chip.textColor = .label
                chip.layer.cornerRadius = 13
                chip.layer.borderWidth = 1.2
                chip.layer.borderColor = accentColor.withAlphaComponent(0.45).cgColor
                chip.layer.masksToBounds = true
                chip.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(chip)
                
                // Position in grid
                if i % chipsPerRow == 0 && i > 0 {
                    currentX = 0
                    currentY += chipHeight + verticalSpacing
                }
                
                NSLayoutConstraint.activate([
                    chip.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
                    chip.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: currentX),
                    chip.widthAnchor.constraint(equalToConstant: chipWidth),
                    chip.heightAnchor.constraint(equalToConstant: chipHeight)
                ])
                
                currentX += chipWidth + horizontalSpacing
                
                // Animation
                chip.alpha = 0
                UIView.animate(withDuration: 0.45, delay: Double(i)*0.08, options: [.curveEaseOut], animations: {
                    chip.alpha = 1
                }, completion: nil)
            }
            
            // Adjust content height
            let numberOfRows = ceil(Double(dateStrings.count) / Double(chipsPerRow))
            let contentHeight = currentY + chipHeight + 10
            
            NSLayoutConstraint.activate([
                contentView.heightAnchor.constraint(equalToConstant: contentHeight)
            ])
            
        } else if statType == .completion {
            // Create a simple chart for completion rate
            let chartView = createCompletionRateChart()
            stack.addArrangedSubview(chartView)
        } else {
            let noDatesLabel = UILabel()
            noDatesLabel.text = "No dates found for this statistic."
            noDatesLabel.font = .systemFont(ofSize: 15, weight: .regular)
            noDatesLabel.textColor = .secondaryLabel
            noDatesLabel.textAlignment = .center
            stack.addArrangedSubview(noDatesLabel)
        }
    }
    
    private func createCompletionRateChart() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        // Extract completion rate from message (e.g., "Your completion rate is 75%...")
        var completionRate: CGFloat = 0.0
        if let percentStr = msg.components(separatedBy: "is ").last?.components(separatedBy: "%").first,
           let percent = Float(percentStr) {
            completionRate = CGFloat(percent) / 100.0
        }
        
        // Base bar (background)
        let baseBar = UIView()
        baseBar.translatesAutoresizingMaskIntoConstraints = false
        baseBar.backgroundColor = UIColor.systemGray5
        baseBar.layer.cornerRadius = 8
        containerView.addSubview(baseBar)
        
        // Filled bar (progress)
        let filledBar = UIView()
        filledBar.translatesAutoresizingMaskIntoConstraints = false
        filledBar.backgroundColor = accentColor
        filledBar.layer.cornerRadius = 8
        containerView.addSubview(filledBar)
        
        // Percentage label
        let percentLabel = UILabel()
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        percentLabel.textColor = .white
        percentLabel.text = "\(Int(completionRate * 100))%"
        percentLabel.textAlignment = .right
        filledBar.addSubview(percentLabel)
        
        NSLayoutConstraint.activate([
            baseBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            baseBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            baseBar.heightAnchor.constraint(equalToConstant: 40),
            baseBar.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            filledBar.leadingAnchor.constraint(equalTo: baseBar.leadingAnchor),
            filledBar.heightAnchor.constraint(equalTo: baseBar.heightAnchor),
            filledBar.centerYAnchor.constraint(equalTo: baseBar.centerYAnchor),
            filledBar.widthAnchor.constraint(equalTo: baseBar.widthAnchor, multiplier: max(0.05, completionRate)),
            
            percentLabel.centerYAnchor.constraint(equalTo: filledBar.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: filledBar.trailingAnchor, constant: -12)
        ])
        
        // Animation
        filledBar.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseOut, animations: {
            filledBar.alpha = 1
        }, completion: nil)
        
        return containerView
    }

    private func statIcon() -> String {
        switch statType {
        case .streak: return "🔥"
        case .completion: return "📊"
        case .done:   return "✅"
        case .weekly: return "📅"
        case .bestDay: return "⭐️"
        case .longestGap: return "⚠️"
        case .trend: return "📈"
        }
    }
    
    private func accentBarColors() -> [CGColor] {
        switch statType {
        case .streak:
            return [UIColor.systemOrange.withAlphaComponent(0.8).cgColor,
                    UIColor.systemRed.withAlphaComponent(0.8).cgColor]
        case .completion:
            return [UIColor.systemPurple.withAlphaComponent(0.78).cgColor,
                    UIColor.systemIndigo.withAlphaComponent(0.65).cgColor]
        case .done:
            return [UIColor.systemGreen.withAlphaComponent(0.9).cgColor,
                    UIColor.systemGreen.withAlphaComponent(0.5).cgColor]
        case .weekly:
            return [UIColor.systemIndigo.withAlphaComponent(0.9).cgColor,
                    UIColor.systemBlue.withAlphaComponent(0.7).cgColor]
        case .bestDay:
            return [UIColor.systemYellow.withAlphaComponent(0.9).cgColor,
                    UIColor.systemOrange.withAlphaComponent(0.7).cgColor]
        case .longestGap:
            return [UIColor.systemRed.withAlphaComponent(0.9).cgColor,
                    UIColor.systemPink.withAlphaComponent(0.7).cgColor]
        case .trend:
            return [UIColor.systemGreen.withAlphaComponent(0.9).cgColor,
                    UIColor.systemTeal.withAlphaComponent(0.7).cgColor]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sheet = self.sheetPresentationController {
            let baseHeight: CGFloat = 260
            let dateRows = CGFloat(max(1, (dateStrings.count+2)/3))
            let sheetHeight = baseHeight + dateRows*45
            sheet.detents = [
                .custom(resolver: { _ in min(sheetHeight, UIScreen.main.bounds.height*0.56) })
            ]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 28
        }
    }
}

// Required extension for UIColor (light check)
extension UIColor {
    var analyticsisLight: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        // Perceived luminance
        return (r*299 + g*587 + b*114)/1000 > 0.72
    }
}
