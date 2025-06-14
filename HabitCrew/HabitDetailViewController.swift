//
//  HabitDetailViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 13/06/25.
//

import UIKit

class HabitDetailViewController: UIViewController {

    private let habit: Habit

    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
        self.title = "Habit Details"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let iconView = UIImageView(image: UIImage(systemName: habit.icon))
        iconView.tintColor = UIColor(hex: habit.colorHex) ?? .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = habit.title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let friendLabel = UILabel()
        friendLabel.text = "Buddy: \(habit.friend)"
        friendLabel.textColor = .secondaryLabel
        friendLabel.font = .systemFont(ofSize: 18)
        friendLabel.translatesAutoresizingMaskIntoConstraints = false

        let noteLabel = UILabel()
        noteLabel.text = habit.note ?? "No notes"
        noteLabel.font = .systemFont(ofSize: 17)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        let createdLabel = UILabel()
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        createdLabel.text = "Created: \(df.string(from: habit.createdAt))"
        createdLabel.font = .systemFont(ofSize: 15)
        createdLabel.textColor = .secondaryLabel
        createdLabel.translatesAutoresizingMaskIntoConstraints = false

        let motivationLabel = UILabel()
        if let motivation = habit.motivation, !motivation.isEmpty {
            motivationLabel.text = "Motivation: \(motivation)"
        } else {
            motivationLabel.text = "No motivation set."
        }
        motivationLabel.font = .italicSystemFont(ofSize: 18)
        motivationLabel.textAlignment = .center
        motivationLabel.numberOfLines = 0
        motivationLabel.textColor = .systemBlue
        motivationLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [
            iconView, titleLabel, friendLabel, noteLabel, motivationLabel, createdLabel
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
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
}
