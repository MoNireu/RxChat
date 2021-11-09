//
//  ViewController.swift
//  RxChat
//
//  Created by MoNireu on 2021/07/08.
//

import UIKit
import RxSwift
import GoogleSignIn

class SignInViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: SignInViewModel!
    var disposeBag = DisposeBag()
    @IBOutlet weak var signInButtonBackGround: GIDSignInButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButtonBackGround.style = .wide
    }
    
    @IBAction func signIn(_ sender: Any) {
        viewModel.signInComplete.execute()
    }
    
    
    func bindViewModel() {
        viewModel.actIndicatorSubject
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
}
