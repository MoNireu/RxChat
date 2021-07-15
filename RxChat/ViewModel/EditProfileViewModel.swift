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


class EditProfileViewModel: CommonViewModel {
    let disposeBag = DisposeBag()
    var ownerInfo: User
    var ownerInfoSubject: BehaviorSubject<User>
    
    init(ownerInfo: User, sceneCoordinator: SceneCoordinatorType) {
        self.ownerInfo = ownerInfo
        ownerInfoSubject = BehaviorSubject<User>(value: ownerInfo)
        super.init(sceneCoordinator: sceneCoordinator)
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

            return Observable.empty()
        }
    }
    
    
}
