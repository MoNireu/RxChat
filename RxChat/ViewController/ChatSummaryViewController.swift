//
//  ChatSummaryViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/29.
//

import UIKit

class ChatSummaryViewController: UIViewController, ViewModelBindableType {
    
    let CONTENT_HEIGHT: CGFloat = 470
    var viewModel: ChatSummaryViewModel!
    
    
    @IBOutlet weak var friendNameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showProfileDetailBtn: UIButton!
    @IBOutlet weak var showChatBtn: UIButton!
    
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
        viewModel.sceneCoordinator.closed()
    }
    
    func bindViewModel() {
        
    }
    
}
