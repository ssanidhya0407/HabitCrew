import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = OnboardingViewController()
        window?.makeKeyAndVisible()
    }
    
    
    func setPresenceOnline(_ online: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        if online {
            db.collection("users").document(uid).setData([
                "isOnline": true
            ], merge: true)
        } else {
            db.collection("users").document(uid).setData([
                "isOnline": false,
                "lastSeen": FieldValue.serverTimestamp()
            ], merge: true)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        setPresenceOnline(true)
    }
    func sceneWillResignActive(_ scene: UIScene) {
        setPresenceOnline(false)
    }
}
