//
//  ChatSummaryViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ChatSummaryViewController: UIViewController, ViewModelBindableType {
    
    let CONTENT_HEIGHT: CGFloat = 500
    var viewModel: ChatSummaryViewModel!
    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showProfileDetailBtn: UIButton!
    @IBOutlet weak var showChatBtn: UIButton!
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height * 0.5
        super.viewDidLoad()
    }
    
    override func updateViewConstraints() {
        self.view.frame.origin.y = UIScreen.main.bounds.height - CONTENT_HEIGHT
        self.view.layer.cornerRadius = CONTENT_HEIGHT * 0.03
        super.updateViewConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Log -", #fileID, #function, #line, "View Disappear")
        viewModel.sceneCoordinator.closed()
    }
    
    func bindViewModel() {
        viewModel.userDriver
            .drive(onNext: { [weak self] user in
                self?.profileImageView.image = user.profileImg
                self?.nameLbl.text = user.name
            }).disposed(by: rx.disposeBag)
        
        showChatBtn.rx.action = viewModel.chatFriend
    }
}
