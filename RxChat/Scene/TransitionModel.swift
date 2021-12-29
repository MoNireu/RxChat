//
//  TransitionModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation


enum TransitionStyle {
    case root
    case push
    case modal
    case fullScreen
    case pushOnParent
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
