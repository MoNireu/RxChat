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
    let friendListDelegate: FriendListViewModel
    var foundUser: User?
    lazy var foundUserSubject: BehaviorSubject<User?> = BehaviorSubject<User?>(value: foundUser)
    
    init(friendListDelegate: FriendListViewModel, sceneCoordinator: SceneCoordinatorType, firebaseUtil: FirebaseUtil) {
        self.friendListDelegate = friendListDelegate
        super.init(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
    }
    
    deinit {
        print("Log -", #fileID, #function, #line, "deinit")
    }
    
    lazy var findUser: Action<String, Void> = {
        return Action<String, Void> { email in
            self.firebaseUtil.findUser(email)
                .subscribe(onNext: { user in
                    self.foundUser = user
                    self.foundUserSubject.onNext(self.foundUser)
                },
                onError: { _ in
                    self.foundUser = nil
                    self.foundUserSubject.onNext(self.foundUser)
                }).disposed(by: self.disposeBag)
            
            return Observable.empty()
        }
    }()
    
    
    lazy var addFriend: CocoaAction = {
        return CocoaAction { _ in
            return Observable.create { observer in
                // Add Friend to Firestore
                self.firebaseUtil.addFriend(ownerUID: Owner.shared.uid, newFriend: self.foundUser!)
                    .subscribe(onCompleted: {
                        observer.onCompleted()
                        // TODO: TODO
                        // if add friend to firestore complete
                        // Add Friend to FriendListVC Tableview.
                        
                        Owner.shared.friendList.updateValue(self.foundUser!, forKey: self.foundUser!.id!)
                        
                        
                        RealmUtil.shared.writeSingleFriend(friendInfo: self.foundUser!)
                        
                    }).disposed(by: self.disposeBag)
                
                return Disposables.create()
            }
        }
    }()
    
    
    
}
