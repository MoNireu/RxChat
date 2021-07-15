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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func bindViewModel() {
        
    }


}

