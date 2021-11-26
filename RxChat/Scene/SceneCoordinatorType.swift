//
//  SceneCoordinatorType.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation
import UIKit
import RxSwift

protocol SceneCoordinatorType {
    func getCurrentVC() -> UIViewController
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
        
    @discardableResult
    func closed()
}
