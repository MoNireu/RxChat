//
//  ViewExtension.swift
//  RxChat
//
//  Created by MoNireu on 2022/01/10.
//

import Foundation
import UIKit

extension UIView {
    func setCornerRadius(value: Float) {
        self.layer.cornerRadius = self.frame.size.width * CGFloat(value)
        self.clipsToBounds = true
    }
}
