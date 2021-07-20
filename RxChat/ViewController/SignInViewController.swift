//
//  ViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/08.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleSignIn

class SignInViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: SignInViewModel!
    @IBOutlet weak var signInButtonBackGround: GIDSignInButton!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButtonBackGround.style = .wide
    }
    
    @IBAction func signIn(_ sender: Any) {
        viewModel.signInComplete.execute()
    }
    
    
    func bindViewModel() {
    }
    
}
