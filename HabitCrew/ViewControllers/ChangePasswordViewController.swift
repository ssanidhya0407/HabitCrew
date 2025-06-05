//
//  ChangePasswordViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    // UI Components
    private let currentPasswordTextField = UITextField()
    private let newPasswordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let changeButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Change Password"
        
        // Current Password Text Field
        currentPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        currentPasswordTextField.placeholder = "Current Password"
        currentPasswordTextField.borderStyle = .roundedRect
        currentPasswordTextField.isSecureTextEntry = true
        currentPasswordTextField.textContentType = .password
        view.addSubview(currentPasswordTextField)
        
        // New Password Text Field
        newPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        newPasswordTextField.placeholder = "New Password"
        newPasswordTextField.borderStyle = .roundedRect
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.textContentType = .newPassword
        view.addSubview(newPasswordTextField)
        
        // Confirm Password Text Field
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.placeholder = "Confirm New Password"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.textContentType = .newPassword
        view.addSubview(confirmPasswordTextField)
        
        // Change Button
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("Change Password", for: .normal)
        changeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        changeButton.backgroundColor = .systemBlue
        changeButton.setTitleColor(.white, for: .normal)
        changeButton.layer.cornerRadius = 10
        changeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        view.addSubview(changeButton)
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            currentPasswordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            newPasswordTextField.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 20),
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            changeButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            changeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            changeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            changeButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func changeButtonTapped() {
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty,
              let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Check if new password and confirm password match
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "New passwords don't match")
            return
        }
        
        // Check if new password meets requirements (minimum 8 characters)
        guard newPassword.count >= 8 else {
            showAlert(title: "Error", message: "New password must be at least 8 characters long")
            return
        }
        
        activityIndicator.startAnimating()
        changeButton.isEnabled = false
        
        // Get current user email for reauthentication
        guard let user = Auth.auth().currentUser, let email = user.email else {
            activityIndicator.stopAnimating()
            changeButton.isEnabled = true
            showAlert(title: "Error", message: "User not logged in or email not available")
            return
        }
        
        // Reauthenticate user before changing password
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.changeButton.isEnabled = true
                    self?.showAlert(title: "Error", message: "Current password is incorrect: \(error.localizedDescription)")
                }
                return
            }
            
            // Change password
            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.changeButton.isEnabled = true
                    
                    if let error = error {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self?.showAlert(title: "Success", message: "Password changed successfully") { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alertController, animated: true)
    }
}