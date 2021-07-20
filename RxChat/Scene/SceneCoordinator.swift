//
//  SceneCoordinator.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation
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
        
        let target = scene.instantiate()
        
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
            subject.onCompleted()
        case .modal:
            subject.onCompleted()
        }
        
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
}

