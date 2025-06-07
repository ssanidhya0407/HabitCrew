//
//  MiniCalendarView.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 06/06/25.
//


//
//  MiniCalendarView.swift
//  HabitCrew
//
//  Created on 2025-06-06
//  Mini Calendar View - Compact calendar for habit tracking
//

import UIKit

/// Compact calendar view for date navigation and habit completion visualization
class MiniCalendarView: UIView {
    
    // MARK: - Properties
    
    private let headerStackView = UIStackView()
    private let monthLabel = UILabel()
    private let prevButton = UIButton()
    private let nextButton = UIButton()
    private let daysCollectionView: UICollectionView
    private let weekdayLabels = UIStackView()
    
    private var calendar = Calendar.current
    private var currentDate = Date()
    private var selectedDate = Date()
    private var completionDates: Set<Date> = []
    
    weak var delegate: MiniCalendarViewDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        
        daysCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        setupCalendar()
    }
    
    required init?(coder: NSCoder) {
        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        
        daysCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(coder: coder)
        setupCalendar()
    }
    
    // MARK: - Setup
    
    private func setupCalendar() {
        backgroundColor = .backgroundSecondary
        applyCornerRadius(.large)
        
        setupHeader()
        setupWeekdayLabels()
        setupCollectionView()
        setupLayout()
        setupAccessibility()
        
        updateCalendar()
    }
    
    private func setupHeader() {
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .horizontal
        headerStackView.distribution = .fillProportionally
        headerStackView.alignment = .center
        addSubview(headerStackView)
        
        // Previous button
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = .textSecondary
        prevButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        headerStackView.addArrangedSubview(prevButton)
        
        // Month label
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = .headline
        monthLabel.textColor = .textPrimary
        monthLabel.textAlignment = .center
        headerStackView.addArrangedSubview(monthLabel)
        
        // Next button
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = .textSecondary
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        headerStackView.addArrangedSubview(nextButton)
    }
    
    private func setupWeekdayLabels() {
        weekdayLabels.translatesAutoresizingMaskIntoConstraints = false
        weekdayLabels.axis = .horizontal
        weekdayLabels.distribution = .fillEqually
        weekdayLabels.spacing = 2
        addSubview(weekdayLabels)
        
        let weekdays = calendar.shortWeekdaySymbols
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday.uppercased()
            label.font = .caption
            label.textColor = .textSecondary
            label.textAlignment = .center
            weekdayLabels.addArrangedSubview(label)
        }
    }
    
    private func setupCollectionView() {
        daysCollectionView.translatesAutoresizingMaskIntoConstraints = false
        daysCollectionView.backgroundColor = .clear
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        daysCollectionView.isScrollEnabled = false
        addSubview(daysCollectionView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Header
            headerStackView.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.medium),
            headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            headerStackView.heightAnchor.constraint(equalToConstant: 32),
            
            // Weekday labels
            weekdayLabels.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: Spacing.medium),
            weekdayLabels.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            weekdayLabels.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            weekdayLabels.heightAnchor.constraint(equalToConstant: 24),
            
            // Collection view
            daysCollectionView.topAnchor.constraint(equalTo: weekdayLabels.bottomAnchor, constant: Spacing.small),
            daysCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.medium),
            daysCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            daysCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.medium),
            daysCollectionView.heightAnchor.constraint(equalToConstant: 180) // 6 rows * 30 height
        ])
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityLabel = "Calendar"
        
        prevButton.accessibilityLabel = "Previous month"
        nextButton.accessibilityLabel = "Next month"
    }
    
    // MARK: - Calendar Updates
    
    private func updateCalendar() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: currentDate)
        
        daysCollectionView.reloadData()
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentDate),
              let firstOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let numberOfDays = monthRange.count
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days of the month
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Fill remaining cells to complete the grid (6 rows * 7 columns = 42 cells)
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    // MARK: - Public Methods
    
    func setCompletionDates(_ dates: Set<Date>) {
        completionDates = dates
        daysCollectionView.reloadData()
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        currentDate = date
        updateCalendar()
        delegate?.miniCalendar(self, didSelectDate: date)
    }
    
    // MARK: - Actions
    
    @objc private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
        updateCalendar()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
        updateCalendar()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Collection View DataSource & Delegate

extension MiniCalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42 // 6 rows * 7 columns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        
        let days = getDaysInMonth()
        let date = days[indexPath.item]
        
        let isSelected = date != nil && calendar.isDate(date!, inSameDayAs: selectedDate)
        let isToday = date != nil && calendar.isDate(date!, inSameDayAs: Date())
        let hasCompletion = date != nil && completionDates.contains { calendar.isDate($0, inSameDayAs: date!) }
        
        cell.configure(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            hasCompletion: hasCompletion
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let days = getDaysInMonth()
        guard let date = days[indexPath.item] else { return }
        
        selectDate(date)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 7 // 6 spacing gaps between 7 items
        return CGSize(width: width, height: 30)
    }
}

// MARK: - Calendar Day Cell

class CalendarDayCell: UICollectionViewCell {
    
    private let dayLabel = UILabel()
    private let completionIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        // Day label
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = .bodySmall
        dayLabel.textAlignment = .center
        contentView.addSubview(dayLabel)
        
        // Completion indicator
        completionIndicator.translatesAutoresizingMaskIntoConstraints = false
        completionIndicator.backgroundColor = .accentMint
        completionIndicator.layer.cornerRadius = 3
        completionIndicator.isHidden = true
        contentView.addSubview(completionIndicator)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            completionIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            completionIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            completionIndicator.widthAnchor.constraint(equalToConstant: 6),
            completionIndicator.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
    
    func configure(date: Date?, isSelected: Bool, isToday: Bool, hasCompletion: Bool) {
        if let date = date {
            let day = Calendar.current.component(.day, from: date)
            dayLabel.text = "\(day)"
            dayLabel.textColor = .textPrimary
            
            // Configure selection state
            if isSelected {
                backgroundColor = .accentMint
                dayLabel.textColor = .white
                layer.cornerRadius = 8
            } else if isToday {
                backgroundColor = .accentMint.withAlphaComponent(0.2)
                dayLabel.textColor = .accentMint
                layer.cornerRadius = 8
            } else {
                backgroundColor = .clear
                layer.cornerRadius = 0
            }
            
            // Show completion indicator
            completionIndicator.isHidden = !hasCompletion
            
            // Accessibility
            isAccessibilityElement = true
            accessibilityLabel = "Day \(day)"
            accessibilityTraits = [.button]
            if hasCompletion {
                accessibilityValue = "Has completed habits"
            }
            
        } else {
            dayLabel.text = ""
            backgroundColor = .clear
            completionIndicator.isHidden = true
            isAccessibilityElement = false
        }
    }
}

// MARK: - Delegate Protocol

protocol MiniCalendarViewDelegate: AnyObject {
    func miniCalendar(_ calendar: MiniCalendarView, didSelectDate date: Date)
}