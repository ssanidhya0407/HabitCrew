import UIKit
import FirebaseAuth
import FirebaseFirestore

class AnalyticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UI Elements
    private let gradientLayer = CAGradientLayer()
    private let calendarHeaderContainer = UIView()
    private var calendarHeaderTop: NSLayoutConstraint!
    private var calendarHeaderHeight: NSLayoutConstraint!

    private let header = AnalyticsHeader(title: "Progress 📈", subtitle: "See your habit journey")
    private let motivationCard = MotivationCard()
    private let calendarCard = CalendarCardView()
    private let analyticsTable = UITableView()
    private var habits: [AnalyticsHabit] = []

    private let collapsedCalendarHeight: CGFloat = 90      // Collapsed (row) height
    private let expandedCalendarHeight: CGFloat = 312      // Expanded calendar height

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        fetchAndDisplayAnalytics()
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
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.addSubview(motivationCard)
        NSLayoutConstraint.activate([
            motivationCard.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            motivationCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            motivationCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            motivationCard.heightAnchor.constraint(equalToConstant: 54)
        ])

        // --- Sticky/Transforming Calendar Implementation ---
        view.addSubview(calendarHeaderContainer)
        calendarHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        calendarHeaderContainer.addSubview(calendarCard)
        calendarCard.translatesAutoresizingMaskIntoConstraints = false

        calendarHeaderTop = calendarHeaderContainer.topAnchor.constraint(equalTo: motivationCard.bottomAnchor, constant: 16)
        calendarHeaderHeight = calendarHeaderContainer.heightAnchor.constraint(equalToConstant: expandedCalendarHeight)
        NSLayoutConstraint.activate([
            calendarHeaderTop,
            calendarHeaderContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarHeaderContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarHeaderHeight,

            calendarCard.leadingAnchor.constraint(equalTo: calendarHeaderContainer.leadingAnchor),
            calendarCard.trailingAnchor.constraint(equalTo: calendarHeaderContainer.trailingAnchor),
            calendarCard.topAnchor.constraint(equalTo: calendarHeaderContainer.topAnchor),
            calendarCard.bottomAnchor.constraint(equalTo: calendarHeaderContainer.bottomAnchor),
        ])

        analyticsTable.backgroundColor = .clear
        analyticsTable.separatorStyle = .none
        analyticsTable.delegate = self
        analyticsTable.dataSource = self
        analyticsTable.register(AnalyticsHabitCardView.self, forCellReuseIdentifier: "HabitCard")
        analyticsTable.translatesAutoresizingMaskIntoConstraints = false
        analyticsTable.showsVerticalScrollIndicator = false
        analyticsTable.rowHeight = 100
        analyticsTable.estimatedRowHeight = 80
        view.addSubview(analyticsTable)
        NSLayoutConstraint.activate([
            analyticsTable.topAnchor.constraint(equalTo: calendarHeaderContainer.bottomAnchor, constant: 16),
            analyticsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            analyticsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            analyticsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(analyticsTable)

        // -- Calendar row mode tap handler --
        calendarCard.rowCalendarView.onDateSelected = { [weak self] date, habits in
            self?.showHabitSheet(for: date, habits: habits)
        }
        // -- ElegantMonthCalendarView tap handler --
        calendarCard.fullCalendarView.onDateTapped = { [weak self] date, habits in
            self?.showHabitSheet(for: date, habits: habits)
        }
    }

    // MARK: - Sticky/Collapsing Calendar Animation
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = max(0, scrollView.contentOffset.y)
        // If scrolled past a threshold, show row mode, else show full calendar
        if offsetY > 80 {
            calendarCard.showRowMode()
            calendarHeaderHeight.constant = collapsedCalendarHeight
        } else {
            calendarCard.showFullMonthMode()
            calendarHeaderHeight.constant = expandedCalendarHeight
        }
        let minHeight = collapsedCalendarHeight
        let maxHeight = expandedCalendarHeight
        let newHeight = calendarHeaderHeight.constant
        let progress = min(1, max(0, (maxHeight - newHeight) / (maxHeight - minHeight)))
        calendarCard.layer.shadowOpacity = Float(0.13 + 0.10 * progress)
        calendarCard.alpha = 1 - 0.10 * progress
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCard", for: indexPath) as! AnalyticsHabitCardView
        cell.configure(with: habit)
        cell.onDetailsTapped = { [weak self] in
            self?.showHabitDetails(habit)
        }
        return cell
    }
    
    // Open habit details screen when tapped
    func showHabitDetails(_ habit: AnalyticsHabit) {
        let detailsVC = HabitAnalyticsDetailViewController(analyticsHabit: habit)
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    // MARK: - Data
    private func fetchAndDisplayAnalytics() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).collection("habits")
            .getDocuments { [weak self] (snapshot, error) in
                if let error = error { print("Firestore error: \(error)") }
                guard let self = self, let docs = snapshot?.documents else { return }
                self.habits = docs.compactMap { doc in
                    let data = doc.data()
                    guard let title = data["title"] as? String else { return nil }
                    guard let doneDatesRaw = data["doneDates"] as? [String: Any] else { return nil }
                    var doneDates: [String: Bool] = [:]
                    for (key, value) in doneDatesRaw {
                        if let b = value as? Bool { doneDates[key] = b }
                        else if let n = value as? NSNumber { doneDates[key] = n.boolValue }
                        else if let i = value as? Int { doneDates[key] = i != 0 }
                        else { doneDates[key] = false }
                    }
                    let colorHex = (data["colorHex"] as? String) ?? "#FFD29C"
                    let icon = (data["icon"] as? String) ?? "circle"
                    let completedDates: [Date] = doneDates.filter { $0.value }.compactMap {
                        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
                        return df.date(from: $0.key)
                    }
                    var daysArray: [Int] = []
                    if let daysRaw = data["days"] as? [Any] {
                        daysArray = daysRaw.compactMap { n in
                            if let i = n as? Int { return i }
                            if let n = n as? NSNumber { return n.intValue }
                            return nil
                        }
                    }
                    var timeString: String? = nil
                    if let t = data["timeString"] as? String {
                        timeString = t
                    } else if let ts = data["schedule"] as? Timestamp {
                        let date = ts.dateValue()
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        formatter.dateStyle = .none
                        timeString = formatter.string(from: date)
                    }
                    return AnalyticsHabit(
                        title: title,
                        colorHex: colorHex,
                        icon: icon,
                        completedDates: completedDates,
                        daysArray: daysArray,
                        timeString: timeString
                    )
                }
                let allDates = Set(self.habits.flatMap { $0.completedDates.map { $0.stripTime() } })
                self.calendarCard.setHighlightedDates(Array(allDates))
                self.calendarCard.rowCalendarView.habits = self.habits
                self.calendarCard.fullCalendarView.habits = self.habits
                DispatchQueue.main.async {
                    self.analyticsTable.reloadData()
                }
                let totalCheckins = self.habits.flatMap { $0.completedDates }
                if totalCheckins.isEmpty {
                    self.motivationCard.setText("Start your journey. Every check-in builds a better you!")
                } else if let best = self.habits.max(by: { $0.currentStreak < $1.currentStreak }), best.currentStreak > 5 {
                    self.motivationCard.setText("🔥 You're on a \(best.currentStreak)-day streak for \(best.title)!")
                } else {
                    self.motivationCard.setText("Keep going, consistency leads to results!")
                }
            }
    }

    // --- Elegant Habit Sheet for Date ---
    func showHabitSheet(for date: Date, habits: [AnalyticsHabit]) {
        let sheet = HabitSheetViewController(date: date, habits: habits)
        present(sheet, animated: true)
    }
}

// MARK: - MODULAR UI COMPONENTS

class AnalyticsHeader: UIView {
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

class MotivationCard: UIView {
    private let label = UILabel()
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.11)
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    func setText(_ text: String) { label.text = text }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}


// --- MODIFIED CALENDAR CARD VIEW ---
class CalendarCardView: UIView {
    let fullCalendarView = ElegantMonthCalendarView()
    let rowCalendarView = CalendarRowView()
    private let bg = UIView()
    private var isRowMode = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.backgroundColor = .white
        bg.layer.cornerRadius = 24
        bg.layer.shadowColor = UIColor.systemGray4.cgColor
        bg.layer.shadowOpacity = 0.13
        bg.layer.shadowRadius = 10
        bg.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(bg)

        fullCalendarView.translatesAutoresizingMaskIntoConstraints = false
        rowCalendarView.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(fullCalendarView)
        bg.addSubview(rowCalendarView)
        rowCalendarView.alpha = 0

        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: trailingAnchor),
            bg.topAnchor.constraint(equalTo: topAnchor),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor),

            fullCalendarView.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            fullCalendarView.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            fullCalendarView.topAnchor.constraint(equalTo: bg.topAnchor, constant: 7),
            fullCalendarView.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -7),

            rowCalendarView.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            rowCalendarView.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            rowCalendarView.topAnchor.constraint(equalTo: bg.topAnchor, constant: 7),
            rowCalendarView.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -7),
        ])
    }
    func setHighlightedDates(_ dates: [Date]) {
        fullCalendarView.highlightedDates = dates
        rowCalendarView.highlightedDates = dates
    }
    func showRowMode(animated: Bool = true) {
        guard !isRowMode else { return }
        isRowMode = true
        if animated {
            UIView.animate(withDuration: 0.28) {
                self.fullCalendarView.alpha = 0
                self.rowCalendarView.alpha = 1
            }
        } else {
            self.fullCalendarView.alpha = 0
            self.rowCalendarView.alpha = 1
        }
    }
    func showFullMonthMode(animated: Bool = true) {
        guard isRowMode else { return }
        isRowMode = false
        if animated {
            UIView.animate(withDuration: 0.28) {
                self.fullCalendarView.alpha = 1
                self.rowCalendarView.alpha = 0
            }
        } else {
            self.fullCalendarView.alpha = 1
            self.rowCalendarView.alpha = 0
        }
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}

// --- NEW: Row mode calendar, 5 day bubbles centered on today ---
class CalendarRowView: UIView {
    var highlightedDates: [Date] = [] {
        didSet { setNeedsLayout() }
    }
    var habits: [AnalyticsHabit] = [] {
        didSet { setNeedsLayout() }
    }
    var onDateSelected: ((Date, [AnalyticsHabit]) -> Void)?

    private var dayLabels: [UILabel] = []

    override func layoutSubviews() {
        super.layoutSubviews()
        for v in dayLabels { v.removeFromSuperview() }
        dayLabels.removeAll()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var days: [Date] = []
        for i in -2...2 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                days.append(date)
            }
        }

        let bubbleSize: CGFloat = 36
        let spacing: CGFloat = 16
        let totalWidth = bubbleSize * 5 + spacing * 4
        let startX = (bounds.size.width - totalWidth) / 2

        for (i, date) in days.enumerated() {
            let x = startX + CGFloat(i) * (bubbleSize + spacing)
            let label = UILabel(frame: CGRect(x: x, y: bounds.midY - bubbleSize/2, width: bubbleSize, height: bubbleSize))
            let dayNum = Calendar.current.component(.day, from: date)
            label.text = "\(dayNum)"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            label.layer.cornerRadius = bubbleSize / 2
            label.clipsToBounds = true

            // Find all habits scheduled for this date's weekday
            let weekday = ((calendar.component(.weekday, from: date) + 6) % 7) // Sunday=0
            let habitsForDay = habits.filter { $0.scheduledDays?.contains(weekday) == true }
            let colors = habitsForDay.compactMap { UIColor(hex: $0.colorHex) }

            if calendar.isDate(date, inSameDayAs: today) {
                label.backgroundColor = UIColor.systemRed
                label.textColor = .black  // Changed to black
            } else if !colors.isEmpty {
                label.backgroundColor = UIColor.blend(colors: colors)
                label.textColor = .black  // Always black text
            } else {
                label.backgroundColor = UIColor.systemGray5
                label.textColor = UIColor(white: 0.3, alpha: 1) // Darker for better contrast
            }

            label.isUserInteractionEnabled = true
            label.tag = i // 0...4
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDateTap(_:)))
            label.addGestureRecognizer(tap)

            addSubview(label)
            dayLabels.append(label)
        }
    }

    @objc private func handleDateTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel, label.tag >= 0, label.tag < 5 else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let selectedDate = calendar.date(byAdding: .day, value: label.tag - 2, to: today) else { return }
        let weekday = ((calendar.component(.weekday, from: selectedDate) + 6) % 7)
        let filteredHabits = habits.filter { $0.scheduledDays?.contains(weekday) == true }
        onDateSelected?(selectedDate, filteredHabits)
    }
}


// --- ElegantMonthCalendarView with only today bubble and tap sheet support ---
class ElegantMonthCalendarView: UIView {
    var highlightedDates: [Date] = [] { didSet { setNeedsDisplay() } }
    var habits: [AnalyticsHabit] = []
    var onDateTapped: ((Date, [AnalyticsHabit]) -> Void)?

    private var dayRects: [Date: CGRect] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        dayRects.removeAll()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let comp = calendar.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = calendar.date(from: comp) else { return }
        let range = calendar.range(of: .day, in: .month, for: today)!
        let days = range.count

        let mainRed = UIColor.systemRed
        let fadedRed = UIColor.systemRed.withAlphaComponent(0.72)

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        let titleStr = monthFormatter.string(from: today).capitalized
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: mainRed
        ]
        let titleSize = titleStr.size(withAttributes: titleAttrs)
        titleStr.draw(at: CGPoint(x: 28, y: 25), withAttributes: titleAttrs)

        let cellW = (rect.width - 36) / 7
        let weekdaySymbols = calendar.veryShortStandaloneWeekdaySymbols
        for i in 0..<7 {
            let attr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                .foregroundColor: fadedRed
            ]
            let name = weekdaySymbols[i]
            let size = name.size(withAttributes: attr)
            let x = CGFloat(i) * cellW + (cellW - size.width)/2 + 18
            name.draw(at: CGPoint(x: x, y: titleSize.height + 37), withAttributes: attr)
        }

        let numRows = Int(ceil(Double(days + calendar.component(.weekday, from: firstOfMonth) - 1) / 7.0))
        let cellH = (rect.height - titleSize.height - 70) / CGFloat(numRows)
        var dayNum = 1
        var y: CGFloat = titleSize.height + 62
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        for row in 0..<numRows {
            for col in 0..<7 {
                if row == 0 && col < firstWeekday { continue }
                if dayNum > days { break }
                let x = CGFloat(col) * cellW + 18
                let rectDay = CGRect(x: x, y: y, width: cellW, height: cellH)
                let date = calendar.date(byAdding: .day, value: dayNum-1, to: firstOfMonth)!
                let isToday = calendar.isDateInToday(date)

                if isToday {
                    let diameter = min(cellW, cellH) * 0.92
                    let circleRect = CGRect(
                        x: rectDay.midX - diameter/2,
                        y: rectDay.midY - diameter/2,
                        width: diameter, height: diameter)
                    let path = UIBezierPath(ovalIn: circleRect)
                    mainRed.setFill()
                    path.fill()
                    let border = UIBezierPath(ovalIn: circleRect.insetBy(dx: -2.5, dy: -2.5))
                    UIColor.white.setStroke()
                    border.lineWidth = 4
                    border.stroke()
                    dayRects[date.stripTime()] = circleRect
                } else {
                    dayRects[date.stripTime()] = rectDay
                }

                let attr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                    .foregroundColor: isToday ? UIColor.black : mainRed  // Changed to black
                ]
                let dayStr = "\(dayNum)"
                let size = dayStr.size(withAttributes: attr)
                let textX = rectDay.midX - size.width/2
                let textY = rectDay.midY - size.height/2
                dayStr.draw(at: CGPoint(x: textX, y: textY), withAttributes: attr)
                dayNum += 1
            }
            y += cellH
        }
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        for (date, rect) in dayRects {
            if rect.contains(point) {
                let calendar = Calendar.current
                let weekday = ((calendar.component(.weekday, from: date) + 6) % 7)
                let habitsForDay = habits.filter { $0.scheduledDays?.contains(weekday) == true }
                onDateTapped?(date, habitsForDay)
                break
            }
        }
    }
}


// Color blending and helpers
extension UIColor {
    static func blend(colors: [UIColor]) -> UIColor {
        guard !colors.isEmpty else { return .lightGray }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        for color in colors {
            var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0, aa: CGFloat = 0
            color.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
            r += rr
            g += gg
            b += bb
            a += aa
        }
        let count = CGFloat(colors.count)
        return UIColor(red: r/count, green: g/count, blue: b/count, alpha: 1)
    }
    var isDarkColor: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return ((r * 299) + (g * 587) + (b * 114)) / 1000 < 0.5
    }
}

// MARK: - Elegant Habit Sheet

class HabitSheetViewController: UIViewController, UITableViewDataSource {
    let date: Date
    let habits: [AnalyticsHabit]
    let completedHabits: [AnalyticsHabit]
    let tableView = UITableView(frame: .zero, style: .plain)
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    init(date: Date, habits: [AnalyticsHabit]) {
        self.date = date
        self.habits = habits
        let completed = habits.filter { $0.completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) }
        self.completedHabits = completed
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in CGFloat(80 + habits.count * 62) }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 22
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let df = DateFormatter()
        df.dateStyle = .full
        let label = UILabel()
        label.text = df.string(from: date)
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(HabitSheetCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -18)
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { habits.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let isDone = completedHabits.contains(where: { $0.title == habit.title })
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HabitSheetCell
        cell.configure(with: habit, isDone: isDone)
        return cell
    }
}
class HabitSheetCell: UITableViewCell {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let checkView = UIView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkView.translatesAutoresizingMaskIntoConstraints = false
        checkView.layer.cornerRadius = 14
        checkView.layer.masksToBounds = true
        checkView.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        checkView.layer.shadowRadius = 4
        checkView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkView)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            checkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            checkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkView.widthAnchor.constraint(equalToConstant: 28),
            checkView.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: checkView.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with habit: AnalyticsHabit, isDone: Bool) {
        let color = UIColor(hex: habit.colorHex) ?? .systemBlue
        iconView.image = UIImage(systemName: habit.icon)?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = color
        titleLabel.text = habit.title
        checkView.backgroundColor = isDone ? color : UIColor.systemGray4
        let checkSymbol = isDone ? "checkmark" : "xmark"
        let checkIcon = UIImage(systemName: checkSymbol)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        checkView.subviews.forEach { $0.removeFromSuperview() }
        let imgView = UIImageView(image: checkIcon)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        checkView.addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.centerXAnchor.constraint(equalTo: checkView.centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: checkView.centerYAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 16),
            imgView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}


// MARK: - Habit Card View (Matches Welcome/Home Style)

class AnalyticsHabitCardView: UITableViewCell {
    private let card = UIView()
    private let titleLabel = UILabel()
    private let daysStack = UIStackView()
    private let timeLabel = UILabel()
    private let detailsArrow = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    var onDetailsTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with habit: AnalyticsHabit) {
        let color = UIColor(hex: habit.colorHex) ?? .systemBlue
        card.backgroundColor = color.withAlphaComponent(0.15)
        titleLabel.text = habit.title

        // Days row: always 7, round, active/inactive coloring
        let dayLetters = Calendar.current.veryShortWeekdaySymbols
        let days = habit.scheduledDays ?? []
        daysStack.arrangedSubviews.forEach { daysStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        for i in 0..<7 {
            let lbl = UILabel()
            lbl.text = dayLetters[i]
            lbl.font = UIFont.systemFont(ofSize: 13.5, weight: .semibold)
            lbl.textAlignment = .center
            let isActive = days.contains(i)
            lbl.textColor = isActive ? .black : UIColor(white: 0.5, alpha: 1) // Changed to black
            lbl.backgroundColor = isActive ? color : UIColor.systemGray5
            lbl.layer.cornerRadius = 12
            lbl.layer.masksToBounds = true
            lbl.widthAnchor.constraint(equalToConstant: 24).isActive = true
            lbl.heightAnchor.constraint(equalToConstant: 24).isActive = true
            daysStack.addArrangedSubview(lbl)
        }

        // Time label (right-aligned, monospaced)
        timeLabel.text = habit.timeString ?? ""
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15.5, weight: .medium)
        timeLabel.textColor = .black // Changed to black
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(daysStack)
        card.addSubview(timeLabel)
        card.addSubview(detailsArrow)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        detailsArrow.tintColor = .systemGray2
        detailsArrow.translatesAutoresizingMaskIntoConstraints = false

        daysStack.axis = .horizontal
        daysStack.spacing = 5
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        daysStack.alignment = .center
        daysStack.distribution = .fill

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .right

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: detailsArrow.leadingAnchor, constant: -10),
            
            detailsArrow.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            detailsArrow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            detailsArrow.widthAnchor.constraint(equalToConstant: 20),
            detailsArrow.heightAnchor.constraint(equalToConstant: 20),

            daysStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            daysStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            daysStack.heightAnchor.constraint(equalToConstant: 24),

            timeLabel.centerYAnchor.constraint(equalTo: daysStack.centerYAnchor),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: daysStack.trailingAnchor, constant: 14),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
        
        // Make the card tappable for details
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
    }
    
    @objc private func cardTapped() {
        onDetailsTapped?()
    }
}

struct AnalyticsHabit {
    let title: String
    let colorHex: String
    let icon: String
    let completedDates: [Date]
    let daysArray: [Int]
    let timeString: String?
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completed = Set(completedDates.map { calendar.startOfDay(for: $0) })
        var streak = 0
        for i in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { break }
            if completed.contains(day) { streak += 1 }
            else if i == 0 { return 0 }
            else { break }
        }
        return streak
    }
    var scheduledDays: [Int]? { daysArray }
    var completionRate: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var total = 0
        var completed = 0
        let set = Set(completedDates.map { calendar.startOfDay(for: $0) })
        for i in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { break }
            total += 1
            if set.contains(day) { completed += 1 }
        }
        return total > 0 ? Double(completed) / Double(total) : 0
    }
    var lastCheckin: Date? { completedDates.sorted().last }
    func shortDayLetter(for idx: Int) -> String {
        let sym = Calendar.current.veryShortWeekdaySymbols
        return sym[(idx+Calendar.current.firstWeekday-1)%7]
    }
}
private extension Date {
    func stripTime() -> Date {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: comps)!
    }
}
private extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    func darker() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(0, r-0.18), green: max(0, g-0.18), blue: max(0, b-0.18), alpha: a)
    }
}
