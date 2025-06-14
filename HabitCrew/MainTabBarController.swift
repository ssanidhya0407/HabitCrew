//
//  MainTabBarController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 13/06/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Habit List/Home
        let habitsVC = HabitsListViewController()
        let habitsNav = UINavigationController(rootViewController: habitsVC)
        habitsNav.tabBarItem = UITabBarItem(title: "Habits", image: UIImage(systemName: "list.bullet.rectangle.portrait"), selectedImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill"))

        // Analytics
        let analyticsVC = AnalyticsViewController()
        let analyticsNav = UINavigationController(rootViewController: analyticsVC)
        analyticsNav.tabBarItem = UITabBarItem(title: "Progress", image: UIImage(systemName: "chart.bar.xaxis"), selectedImage: UIImage(systemName: "chart.bar.xaxis"))

        // Profile
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))

        // Friends
        let friendsVC = FriendsViewController()
        let friendsNav = UINavigationController(rootViewController: friendsVC)
        friendsNav.tabBarItem = UITabBarItem(title: "Friends", image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill"))

        viewControllers = [habitsNav, analyticsNav, friendsNav, profileNav]
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = true
    }
}
