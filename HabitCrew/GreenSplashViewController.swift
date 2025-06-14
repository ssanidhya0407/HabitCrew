//
//  GreenSplashViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 13/06/25.
//


import UIKit

class GreenSplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGreen

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = "Registered!"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(checkmark)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            checkmark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            checkmark.widthAnchor.constraint(equalToConstant: 85),
            checkmark.heightAnchor.constraint(equalToConstant: 85),

            label.topAnchor.constraint(equalTo: checkmark.bottomAnchor, constant: 24),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true)
        }
    }
}