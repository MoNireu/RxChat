//
//  TransitionModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/15.
//

import Foundation


enum TransitionStyle {
    case push
    case modal
    case fullScreen
}

enum TransitionError: Error {
    case navigationControllerMissing
    case cannotPop
    case unknown
}
