//
//  Owner.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/16.
//

import Foundation
import UIKit


class Owner: User {
    let uid: String
    
    init(uid: String, email: String, id: String?, profileImgData: Data?) {
        self.uid = uid
        
        super.init(email: email, id: id, profileImgData: profileImgData)
    }
}
