//
//  SceneDelegate.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/08.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var signInViewModel: SignInViewModel?
    var sceneCoordinator: SceneCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIViewController()
        
        self.window = window
        window.makeKeyAndVisible()
        
        sceneCoordinator = SceneCoordinator(window: window)
        let firebaseUtil = FirebaseUtil()
        let launchViewModel = LaunchViewModel(sceneCoordinator: sceneCoordinator!, firebaseUtil: firebaseUtil)
        let launchScene = Scene.launch(launchViewModel)
        sceneCoordinator!.transition(to: launchScene, using: .root, animated: false)
        
    }

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("Log -", #fileID, #function, #line, "Scene Did Disconnect")
        if sceneCoordinator?.getCurrentVC().sceneViewController.restorationIdentifier == "CreateProfileVC" {
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
            GIDSignIn.sharedInstance.signOut()
            print("Log -", #fileID, #function, #line, "SignOut Complete")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("Log -", #fileID, #function, #line, "Scene Did Become Active")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("Log -", #fileID, #function, #line, "Scene Will Resign Active")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("Log -", #fileID, #function, #line, "Scene Will Enter Foreground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("Log -", #fileID, #function, #line, "Scene Did Enter Background")
    }


}

