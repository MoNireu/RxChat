//
//  AppDelegate.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/08.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
       
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        return true
    }
    
    // MARK: GoogleSignIn Methods
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
    -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("GoogleSignIn Error: Sign in error!" + error.localizedDescription)
            return
        }

        print("GoogleSign-in Suceed!")

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                print("Error: Firebase Sign-in Failed")
                print(error?.localizedDescription)
                return
            }

            print("Firebase Sign-in Suceed!")

            let uid = authResult!.user.uid
            let email = authResult!.user.email

            print("UID: " + uid)
            print("Email: " + email!)

            let firebaseUtil = FirebaseUtil()
            firebaseUtil.retriveUserData(uid)
                .subscribe(onNext: { user in
                    let ownerInfo: User
                    if user != nil {
                        ownerInfo = user!
                        print("User exist")
                    }
                    else {
                        ownerInfo = User(email: email!, id: nil)
                        print("User not exist")
                    }

                    
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    let signInViewModel = sceneDelegate?.signInViewModel
                    let editProfileViewModel = EditProfileViewModel(ownerInfo: ownerInfo, sceneCoordinator: signInViewModel!.sceneCoordinator)
                    let editProfileScene = Scene.editProfile(editProfileViewModel)
                    signInViewModel?.sceneCoordinator.transition(to: editProfileScene, using: .fullScreen, animated: true)
                })
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

