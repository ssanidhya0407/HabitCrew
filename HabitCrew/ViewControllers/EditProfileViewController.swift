//
//  EditProfileViewController.swift
//  HabitCrew
//
//  Created by Sanidhya's MacBook Pro on 05/06/25.
//


import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class EditProfileViewController: UIViewController {
    
    // UI Components
    private let profileImageView = UIImageView()
    private let changePhotoButton = UIButton(type: .system)
    private let usernameTextField = UITextField()
    private let bioTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // Data
    private var profileImage: UIImage?
    private var imageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Edit Profile"
        
        // Profile Image View
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.backgroundColor = .systemGray4
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.tintColor = .white
        view.addSubview(profileImageView)
        
        // Change Photo Button
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        changePhotoButton.setTitle("Change Photo", for: .normal)
        changePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        view.addSubview(changePhotoButton)
        
        // Username Text Field
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.clearButtonMode = .whileEditing
        view.addSubview(usernameTextField)
        
        // Bio Text View
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.font = UIFont.systemFont(ofSize: 16)
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.borderColor = UIColor.systemGray4.cgColor
        bioTextView.layer.cornerRadius = 8
        bioTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(bioTextView)
        
        // Save Button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            usernameTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 24),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            bioTextView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            bioTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bioTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bioTextView.heightAnchor.constraint(equalToConstant: 150),
            
            saveButton.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadUserData() {
        guard let currentUser = AuthService.shared.currentUser else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        usernameTextField.text = currentUser.username
        bioTextView.text = "Add your bio here" // In a real app, you'd load this from the user's profile
        
        // Load profile image if available
        if let profileImageURL = currentUser.profileImageURL, let url = URL(string: profileImageURL) {
            // In a real app, use SDWebImage or another library to load image
            // For now, just use the placeholder
            profileImageView.image = UIImage(systemName: "person.fill")
            profileImageView.tintColor = .white
        }
    }
    
    @objc private func changePhotoTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(title: "Error", message: "Please enter a username")
            return
        }
        
        guard let user = AuthService.shared.currentUser else {
            return
        }
        
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        
        // First, update profile image if changed
        if imageChanged, let profileImage = profileImage {
            uploadProfileImage(profileImage) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    // Now update user profile with new username and image URL
                    var updatedUser = user
                    updatedUser.username = username
                    updatedUser.profileImageURL = imageURL
                    
                    self?.updateUserProfile(updatedUser)
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.saveButton.isEnabled = true
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        } else {
            // Just update username if image wasn't changed
            var updatedUser = user
            updatedUser.username = username
            updateUserProfile(updatedUser)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "ProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])))
            return
        }
        
        guard let userId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(NSError(domain: "ProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(userId).jpg")
        
        let uploadTask = profileImageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "ProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    private func updateUserProfile(_ user: User) {
        let db = Firestore.firestore()
        db.collection("users").document(user.id).updateData([
            "username": user.username,
            "profileImageURL": user.profileImageURL ?? ""
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.saveButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    // Update local user data
                    AuthService.shared.currentUser = user
                    
                    self?.showAlert(title: "Success", message: "Profile updated successfully") { _ in
                        self?.navigationController?.popViewController(animated: true)
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

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            profileImage = editedImage
            imageChanged = true
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            profileImage = originalImage
            imageChanged = true
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
