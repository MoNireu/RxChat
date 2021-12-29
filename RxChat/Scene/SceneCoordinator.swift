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
        return self.children.first ?? self
    }
}

class SceneCoordinator: SceneCoordinatorType {
    private let bag = DisposeBag()
    
    private var window: UIWindow
    private var currentVC: UIViewController!
    
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
        print("Log -", #fileID, #function, #line, "Load")
        
        print("Log -", #fileID, #function, #line, "from: \(getCurrentVC())")
        
        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
            
        case .fullScreen:
            target.modalPresentationStyle = .fullScreen
            currentVC.present(target, animated: true) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
            
        case .push:
            let currentNAV = currentVC as? UINavigationController
            currentNAV?.pushViewController(target, animated: true)
            subject.onCompleted()
            currentVC = target.sceneViewController
        
        case .modal:
            currentVC.present(target, animated: true) {
                subject.onCompleted()
            }
            currentVC = target.sceneViewController
            
        case .pushOnParent:
            currentVC.dismiss(animated: true) {
                target = scene.instantiate()
                let currentNAV = self.currentVC as? UINavigationController
                currentNAV?.pushViewController(target, animated: true)
                subject.onCompleted()
                self.currentVC = target.sceneViewController
            }
        }
        print("Log -", #fileID, #function, #line, "to: \(getCurrentVC())")
        
        return subject.ignoreElements()
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
        print("Log -", #fileID, #function, #line, self.currentVC.presentingViewController)
        if let presentingVC = self.currentVC.presentingViewController {
            print("Log -", #fileID, #function, #line, "VC")
            self.currentVC = presentingVC.sceneViewController
        }
        else if let parentNAV = self.currentVC.navigationController?.parent {
            print("Log -", #fileID, #function, #line, "NAV")
            self.currentVC = parentNAV.sceneViewController
        }
        else {
            print("close error")
        }
    }
}

