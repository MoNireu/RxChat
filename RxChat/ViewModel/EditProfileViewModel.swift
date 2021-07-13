//
//  EditProfileViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/13.
//

import Foundation
import RxSwift
import RxCocoa
import Action


class EditProfileViewModel {
    let disposeBag = DisposeBag()
    var ownerInfo: User
    var ownerInfoSubject: BehaviorSubject<User>
    
    init(ownerInfo: User) {
        self.ownerInfo = ownerInfo
        ownerInfoSubject = BehaviorSubject<User>(value: ownerInfo)
    }
    
    func profileEditDone() -> CocoaAction {
        return Action { _ in
            self.ownerInfoSubject
                .subscribe(onNext: { user in
                    print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
                    print("Profile Edit Done!")
                    print("email: \(user.email)")
                    print("id: \(user.id)")
                    print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
                })
//            print("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
//            print("Profile Edit Done!")
//            print("email: \(self.ownerInfo.email)")
//            print("id: \(self.ownerInfo.id!)")
//            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑")
            
            return Observable.empty()
        }
    }
    
    
}
