import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - MAIN VIEW CONTROLLER


class AnalyticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UI Elements
    private let gradientLayer = CAGradientLayer()
    private let decorativeBlob1 = UIView()
    private let decorativeBlob2 = UIView()

    private let header = AnalyticsHeader(title: "Progress 📈", subtitle: "See your habit journey")
    private let motivationCard = MotivationCard()
    private let calendarCard = CalendarCardView()
    private let analyticsTable = UITableView()
    private var habits: [AnalyticsHabit] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDecorativeBlobs()
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

    private func setupDecorativeBlobs() {
        decorativeBlob1.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        decorativeBlob1.layer.cornerRadius = 100
        decorativeBlob1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob1)
        NSLayoutConstraint.activate([
            decorativeBlob1.widthAnchor.constraint(equalToConstant: 190),
            decorativeBlob1.heightAnchor.constraint(equalToConstant: 190),
            decorativeBlob1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -48),
            decorativeBlob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -48)
        ])
        decorativeBlob2.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.07)
        decorativeBlob2.layer.cornerRadius = 100
        decorativeBlob2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decorativeBlob2)
        NSLayoutConstraint.activate([
            decorativeBlob2.widthAnchor.constraint(equalToConstant: 190),
            decorativeBlob2.heightAnchor.constraint(equalToConstant: 190),
            decorativeBlob2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 48),
            decorativeBlob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 48)
        ])
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
        view.addSubview(calendarCard)
        NSLayoutConstraint.activate([
            calendarCard.topAnchor.constraint(equalTo: motivationCard.bottomAnchor, constant: 16),
            calendarCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarCard.heightAnchor.constraint(equalToConstant: 312)
        ])
        // Table for cards, with no separators, transparent, like your welcome/home
        analyticsTable.backgroundColor = .clear
        analyticsTable.separatorStyle = .none
        analyticsTable.delegate = self
        analyticsTable.dataSource = self
        analyticsTable.register(AnalyticsHabitCardView.self, forCellReuseIdentifier: "HabitCard")
        analyticsTable.translatesAutoresizingMaskIntoConstraints = false
        analyticsTable.showsVerticalScrollIndicator = false
        analyticsTable.rowHeight = UITableView.automaticDimension
        analyticsTable.rowHeight = 100
        analyticsTable.estimatedRowHeight = 80
        view.addSubview(analyticsTable)
        NSLayoutConstraint.activate([
            analyticsTable.topAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: 16),
            analyticsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            analyticsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            analyticsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(analyticsTable)
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TableView numberOfRowsInSection called. habits.count = \(habits.count)")
        return habits.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell for row \(indexPath.row): \(habits[indexPath.row].title)")
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCard", for: indexPath) as! AnalyticsHabitCardView
        cell.configure(with: habit)
        return cell
    }

    // MARK: - Data


    private func fetchAndDisplayAnalytics() {
        print("fetchAndDisplayAnalytics called")
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No current user UID")
            return
        }
        print("Fetching habits for user: \(uid)")
        Firestore.firestore().collection("users").document(uid).collection("habits")
            .getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("Firestore error: \(error)")
                }
                guard let self = self, let docs = snapshot?.documents else {
                    print("No snapshot?.documents")
                    return
                }
                print("Fetched \(docs.count) docs from Firestore")
                self.habits = docs.compactMap { doc in
                    let data = doc.data()
                    print("Habit doc data: \(data)")
                    guard let title = data["title"] as? String else {
                        print("Skipping doc, missing title: \(data)")
                        return nil
                    }
                    // DoneDates parsing
                    guard let doneDatesRaw = data["doneDates"] as? [String: Any] else {
                        print("Skipping doc, missing doneDates: \(data)")
                        return nil
                    }
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
                    
                    // --- NEW: fetch days array from Firestore ---
                    var daysArray: [Int] = []
                    if let daysRaw = data["days"] as? [Any] {
                        daysArray = daysRaw.compactMap { n in
                            if let i = n as? Int { return i }
                            if let n = n as? NSNumber { return n.intValue }
                            return nil
                        }
                    }
                    
                    // --- NEW: fetch time from Firestore as a string or timestamp ---
                    var timeString: String? = nil
                    if let t = data["timeString"] as? String {
                        timeString = t
                    } else if let ts = data["schedule"] as? Timestamp {
                        // Firestore Timestamp case
                        let date = ts.dateValue()
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        formatter.dateStyle = .none
                        timeString = formatter.string(from: date)
                    }
                    
                    print("Parsed habit: title=\(title), colorHex=\(colorHex), icon=\(icon), daysArray=\(daysArray), timeString=\(String(describing: timeString)), completedDates.count=\(completedDates.count)")
                    return AnalyticsHabit(
                        title: title,
                        colorHex: colorHex,
                        icon: icon,
                        completedDates: completedDates,
                        daysArray: daysArray,
                        timeString: timeString
                    )
                }
                print("Parsed \(self.habits.count) habits")

                let allDates = Set(self.habits.flatMap { $0.completedDates.map { $0.stripTime() } })
                print("All highlighted dates: \(allDates)")
                self.calendarCard.setHighlightedDates(Array(allDates))
                DispatchQueue.main.async {
                    print("Reloading analyticsTable")
                    self.analyticsTable.reloadData()
                }
                // Motivation
                let totalCheckins = self.habits.flatMap { $0.completedDates }
                print("Total checkins: \(totalCheckins.count)")
                if totalCheckins.isEmpty {
                    self.motivationCard.setText("Start your journey. Every check-in builds a better you!")
                } else if let best = self.habits.max(by: { $0.currentStreak < $1.currentStreak }), best.currentStreak > 5 {
                    self.motivationCard.setText("🔥 You're on a \(best.currentStreak)-day streak for \(best.title)!")
                } else {
                    self.motivationCard.setText("Keep going, consistency leads to results!")
                }
            }
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

class CalendarCardView: UIView {
    private let calendarView = ElegantMonthCalendarView()
    private let bg = UIView()

    init() {
        super.init(frame: .zero)
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

        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .clear
        bg.addSubview(calendarView)

        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: trailingAnchor),
            bg.topAnchor.constraint(equalTo: topAnchor),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor),

            calendarView.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            calendarView.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            calendarView.topAnchor.constraint(equalTo: bg.topAnchor, constant: 7),
            calendarView.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -7),
        ])
    }
    func setHighlightedDates(_ dates: [Date]) {
        print("Setting highlighted dates: \(dates)")
        calendarView.highlightedDates = dates
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
}



class ElegantMonthCalendarView: UIView {
    var highlightedDates: [Date] = [] {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        isOpaque = true
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let comp = calendar.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = calendar.date(from: comp) else { return }
        let range = calendar.range(of: .day, in: .month, for: today)!
        let days = range.count

        // Colors
        let mainRed = UIColor.systemRed
        let fadedRed = UIColor.systemRed.withAlphaComponent(0.72)
        let bgBlack = UIColor.black

        // Month Title
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        let titleStr = monthFormatter.string(from: today).capitalized
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: mainRed
        ]
        let titleSize = titleStr.size(withAttributes: titleAttrs)
        titleStr.draw(at: CGPoint(x: 28, y: 25), withAttributes: titleAttrs)

        // Weekdays row
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

        // Days grid
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
                    // Draw big red filled circle for today
                    let diameter = min(cellW, cellH) * 0.92
                    let circleRect = CGRect(
                        x: rectDay.midX - diameter/2,
                        y: rectDay.midY - diameter/2,
                        width: diameter, height: diameter)
                    let path = UIBezierPath(ovalIn: circleRect)
                    mainRed.setFill()
                    path.fill()
                }

                // Day number
                let attr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                    .foregroundColor: isToday ? UIColor.white : mainRed
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
}


// MARK: - Habit Card View (Matches Welcome/Home Style)


class AnalyticsHabitCardView: UITableViewCell {
    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let daysStack = UIStackView()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with habit: AnalyticsHabit) {
        let color = UIColor(hex: habit.colorHex) ?? .systemBlue
        card.backgroundColor = color.withAlphaComponent(0.07)
        iconView.image = UIImage(systemName: habit.icon)?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = color
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
            lbl.textColor = isActive ? .white : UIColor(white: 0.7, alpha: 1)
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
        timeLabel.textColor = color
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 19
        card.layer.masksToBounds = true
        contentView.addSubview(card)
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(daysStack)
        card.addSubview(timeLabel)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label

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

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            daysStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            daysStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            daysStack.heightAnchor.constraint(equalToConstant: 24),

            timeLabel.centerYAnchor.constraint(equalTo: daysStack.centerYAnchor),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: daysStack.trailingAnchor, constant: 14),
            timeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
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

#Preview(){
    AnalyticsViewController()
}
