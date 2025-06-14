//
//  AnalyticsViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 13/06/25.
//


import UIKit

class AnalyticsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Progress"
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "Your analytics will appear here!"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}