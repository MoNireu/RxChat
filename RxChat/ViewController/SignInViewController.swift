//
//  ViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/08.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: SignInViewModel!
    @IBOutlet weak var signInBackGround: GIDSignInButton!
    @IBOutlet weak var signInButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInBackGround.style = .wide
    }
    
    func bindViewModel() {
        signInButton.rx.action = viewModel.signInComplete
    }


}

