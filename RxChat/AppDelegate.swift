//
//  AppDelegate.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/08.
//

import UIKit
import Firebase
import GoogleSignIn
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let disposeBag = DisposeBag()
    let signInConfig = GIDConfiguration.init(clientID: "863245705241-oj0a8jamduf0rmb334n7ee70bnle3lvm.apps.googleusercontent.com")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("GID: SignIn Succeed!")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
            } else {
                // Show the app's signed-in state.
                print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                print("GID: SignIn Failed")
                print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
            }
        }
        return true
    }
    
    // MARK: GoogleSignIn Methods
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
    -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        return false
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
