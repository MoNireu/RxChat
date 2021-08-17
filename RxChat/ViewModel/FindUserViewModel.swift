//
//  FindUserViewModel.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/10.
//

import Foundation
import RxSwift
import RxCocoa
import Action


class FindUserViewModel: CommonViewModel {
    let disposeBag = DisposeBag()
    var ownerInfo: Owner
    
    init(ownerInfo: Owner, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.ownerInfo = ownerInfo
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    
    lazy var findUser: Action<String, User?> = {
        return Action<String, User?> { email in
            return Observable.create { observer in
                self.firebaseUtil.findUser(email)
                    .subscribe(onNext: { user in
                        observer.onNext(user)
                        observer.onCompleted()
                    },
                    onError: { _ in
                        observer.onNext(nil)
                        observer.onCompleted()
                    })
            }
        }
    }()
}
