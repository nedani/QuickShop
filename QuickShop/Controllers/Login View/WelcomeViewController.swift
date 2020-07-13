//
//  WelcomeViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator : NVActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBtn.layer.cornerRadius = 5
        loginBtn.layer.cornerRadius = 5
        resendButton.layer.cornerRadius = 5
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballSpinFadeLoader, color: UIColor.init(named: "color-blue"), padding: nil)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        dismissView()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if textFieldHaveText() {
            //login user
            loginUser()
        }
        else {
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if textFieldHaveText() {
            //register user
            registerUser()
        }
        else {
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
        if emailTextField.text != "" {
            resetThePassword()
        }
        else {
            hud.textLabel.text = "Please insert Email!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func resendEmailPressed(_ sender: UIButton) {
       
        MUser.resendVerificationEmail(email: emailTextField.text!) { (error) in
            
            print("error resending email", error!.localizedDescription)
        }
    }
    
    //MARK:- register user
    private func registerUser() {
        
        showLoadingIndicator()
        MUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Verification Email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                print("error registering", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
    }
    //MARK:- login user
    private func loginUser() {
        
        showLoadingIndicator()
        MUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                if isEmailVerified {
                    self.dismissView()
                    print("email is verified")
                }
                else {
                    self.hud.textLabel.text = "Please verify your Email!"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                    self.resendButton.isHidden = false
                }
            }
            else {
                print("error loging In the user", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            
            self.hideLoadingIndicator()
        }
        
    }
    //MARK:- helpers
    private func dismissView() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func textFieldHaveText() -> Bool {
        
        return (emailTextField.text != "" && passwordTextField.text != "")
    }
    
    private func resetThePassword() {
        
        MUser.resetPassword(email: emailTextField.text!) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Reset password email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            else{
                self.hud.textLabel.text = error?.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    //MARK:- activity Indicator
    
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
}
