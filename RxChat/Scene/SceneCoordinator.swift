//
//  SceneCoordinator.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.last ?? self
    }
}

class SceneCoordinator: SceneCoordinatorType {
    private let bag = DisposeBag()
    
    private var window: UIWindow
    private var tabBarViews = [[UIViewController()], [UIViewController()], [UIViewController()]]
    private var currentTabIndex = 0
    private var currentVC: UIViewController {
        get {
            print("Log -", #fileID, #function, #line, "currentTab: \(currentTabIndex)")
            return tabBarViews[currentTabIndex].last!
        }
        set {
            print("Log -", #fileID, #function, #line, "currentTab: \(currentTabIndex)")
            self.tabBarViews[currentTabIndex].append(newValue)
        }
    }
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    func getCurrentVC() -> UIViewController {
        return currentVC
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        
        
        var target = scene.instantiate()
        

        print("Log -", #fileID, #function, #line, "from: \(getCurrentVC())")
        
        switch style {
        case .root:
            if let target = target as? UITabBarController {
                tabBarViews[0] = [target.viewControllers![0] as! UINavigationController]
                tabBarViews[1] = [target.viewControllers![1] as! UINavigationController]
                tabBarViews[2] = [target.viewControllers![2] as! UINavigationController]
            }
            else {
                tabBarViews[0] = [target]
                tabBarViews[1] = [target]
                tabBarViews[2] = [target]
            }
//            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
            
        case .fullScreen:
            target.modalPresentationStyle = .fullScreen
            currentVC.present(target, animated: true) {
                subject.onCompleted()
            }
//            currentVC = target.sceneViewController
            
            
        case .push:
            let currentNAV = currentVC as? UINavigationController
            currentNAV?.pushViewController(target, animated: true)
            subject.onCompleted()
            currentVC = target.sceneViewController
        
        case .modal:
            print("Log -", #fileID, #function, #line, "Before:\(currentVC)")
            currentVC.present(target, animated: true) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
            print("Log -", #fileID, #function, #line, "After:\(currentVC)")
            
        case .dismissThenPushOnPrivateTab:
            currentVC.dismiss(animated: true) {
                print("Log -", #fileID, #function, #line, "vcAfterDismiss: \(self.currentVC)")
                self.changeTab(index: 1, moveToTabAfterIndexChanged: true)
                target = scene.instantiate()
                self.pushChatRoom(target: target)
                subject.onCompleted()
            }
            
        case .dismissThenPushOnGroupTab:
            currentVC.dismiss(animated: true) {
                print("Log -", #fileID, #function, #line, "vcAfterDismiss: \(self.currentVC)")
                self.changeTab(index: 2, moveToTabAfterIndexChanged: true)
                target = scene.instantiate()
                self.pushChatRoom(target: target)
                subject.onCompleted()
            }
        }
        
        print("Log -", #fileID, #function, #line, "to: \(getCurrentVC())")
        
        return subject.ignoreElements()
    }
    
    
    
    func changeTab(index: Int, moveToTabAfterIndexChanged: Bool = false) {
        self.currentTabIndex = index
        if moveToTabAfterIndexChanged {
            if let tabBar = self.window.rootViewController as? UITabBarController {
                tabBar.selectedIndex = self.currentTabIndex
            }
        }
    }
    
    
//    private func getSceneViewController(target: UIViewController) -> UIViewController {
//        return target.children.first ?? target
//    }
    
    
    fileprivate func pushChatRoom(target: UIViewController) {
        let currentNAV = self.currentVC as? UINavigationController
        currentNAV?.pushViewController(target, animated: true)
        self.currentVC = target.sceneViewController
    }
    
    
    @discardableResult
    func close(animated: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            if let presentingVC = self.currentVC.presentingViewController {
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC.sceneViewController
                    completable(.completed)
                }
            }
            else {
                completable(.error(TransitionError.unknown))
            }
            return Disposables.create()
        }
    }
    
    
    func closed() {
        tabBarViews[currentTabIndex].popLast()
//        if let presentingVC = self.currentVC.presentingViewController {
//            print("Log -", #fileID, #function, #line, "presentingVC: \(presentingVC)")
//            self.currentVC = presentingVC.sceneViewController
//        }
//        else if let parentNAV = self.currentVC.navigationController?.parent {
//            print("Log -", #fileID, #function, #line, "presentingNAV: \(parentNAV)")
//            self.currentVC = parentNAV.sceneViewController
//        }
//        else {
//            print("close error")
//        }
    }
}

