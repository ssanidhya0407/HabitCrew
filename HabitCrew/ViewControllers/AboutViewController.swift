//
//  AboutViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit

class AboutViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    // Data
    private let screenTitle: String
    
    init(title: String) {
        self.screenTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = screenTitle
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Image View
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        contentView.addSubview(imageView)
        
        // Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureContent() {
        switch screenTitle {
        case "Help":
            titleLabel.text = "Help & Support"
            imageView.image = UIImage(systemName: "questionmark.circle")
            descriptionLabel.text = """
            Having trouble with the app? Here are some helpful tips:
            
            1. **Habits not syncing?**
               Make sure you're connected to the internet and try refreshing the app.
               
            2. **Friend requests not working?**
               Check if you've allowed friend requests in Privacy settings.
               
            3. **Not receiving notifications?**
               Go to Settings > Notifications and make sure they're enabled.
               
            4. **Trouble with streaks?**
               Habits must be completed within the set timeframe to maintain streaks.
               
            5. **Need more help?**
               Contact our support team at support@habitapp.com
               
            Our team is ready to assist you with any issues you might encounter!
            """
            
        case "Terms of Service":
            titleLabel.text = "Terms of Service"
            imageView.image = UIImage(systemName: "doc.text")
            descriptionLabel.text = """
            **TERMS OF SERVICE**
            
            Last Updated: June 05, 2025
            
            By downloading, installing, or using this application, you agree to be bound by these Terms of Service.
            
            **1. ACCEPTANCE OF TERMS**
            
            By accessing or using the HabitCrew application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.
            
            **2. DESCRIPTION OF SERVICE**
            
            HabitCrew provides habit tracking and social accountability tools to help users develop and maintain positive habits.
            
            **3. USER ACCOUNTS**
            
            To use certain features of the application, you must register for an account. You are responsible for maintaining the confidentiality of your account information.
            
            **4. USER CONDUCT**
            
            You agree not to use the service for any illegal or unauthorized purpose. You must not transmit any worms, viruses, or any code of a destructive nature.
            
            **5. INTELLECTUAL PROPERTY**
            
            The application and its original content, features, and functionality are owned by HabitCrew and are protected by international copyright, trademark, and other intellectual property laws.
            
            **6. TERMINATION**
            
            We may terminate or suspend your account at any time without prior notice or liability for any reason.
            
            **7. LIMITATION OF LIABILITY**
            
            In no event shall HabitCrew be liable for any indirect, incidental, special, consequential, or punitive damages.
            
            **8. CHANGES TO TERMS**
            
            We reserve the right to modify or replace these Terms at any time. Your continued use of the application after any changes indicates your acceptance of the new Terms.
            
            **9. CONTACT US**
            
            If you have any questions about these Terms, please contact us at legal@habitapp.com.
            """
            
        case "Privacy Policy":
            titleLabel.text = "Privacy Policy"
            imageView.image = UIImage(systemName: "hand.raised")
            descriptionLabel.text = """
            **PRIVACY POLICY**
            
            Last Updated: June 05, 2025
            
            This Privacy Policy describes how HabitCrew collects, uses, and discloses your personal information.
            
            **1. INFORMATION WE COLLECT**
            
            We collect information you provide directly to us, including:
            - Personal information (name, email address)
            - Profile information (username, photo)
            - Content you create (habits, goals, messages)
            
            We also automatically collect certain information, including:
            - Device information
            - Log information
            - Usage data
            
            **2. HOW WE USE YOUR INFORMATION**
            
            We use the information we collect to:
            - Provide, maintain, and improve our services
            - Communicate with you
            - Monitor and analyze trends and usage
            - Prevent fraudulent transactions and enhance security
            
            **3. SHARING OF INFORMATION**
            
            We may share your information:
            - With other users according to your privacy settings
            - With service providers
            - For legal reasons
            
            **4. DATA RETENTION**
            
            We store your information for as long as your account is active or as needed to provide services to you.
            
            **5. SECURITY**
            
            We take reasonable measures to help protect your personal information from loss, theft, misuse, unauthorized access, and alteration.
            
            **6. YOUR CHOICES**
            
            You can access, update, or delete your information through your account settings.
            
            **7. CHANGES TO THIS POLICY**
            
            We may change this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
            
            **8. CONTACT US**
            
            If you have questions about this Privacy Policy, please contact us at privacy@habitapp.com.
            """
            
        default:
            titleLabel.text = screenTitle
            imageView.image = UIImage(systemName: "info.circle")
            descriptionLabel.text = "Information about this topic will be available soon."
        }
    }
}