//
//  EditProfileViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserInfo()
        logoutBtn.layer.cornerRadius = 5
    }

    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        
        dismissKeyboard()
        
        if textFieldsHaveText() {
            let withValues = [Constants.K.user.firstName : nameTextField.text!, Constants.K.user.lastName : surnameTextField.text!, Constants.K.user.fullName : (nameTextField.text! + " " + surnameTextField.text!), Constants.K.user.fullAddress : addressTextField.text!]
            
            updateUserInFirestore(withValues: withValues) { (error) in
                
                if error == nil {
                    
                    self.hud.textLabel.text = "Updated!"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
                else {
                    print("error updating error", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
        }
        else {
            hud.textLabel.text = "All fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        
        logoutUser()
    }
    
    
    //MARK:- update UI
    private func loadUserInfo() {
        
        if MUser.currentUser() != nil {
            let currentUser = MUser.currentUser()!
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    //MARK:- helper
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText()->Bool {
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logoutUser(){
        
        MUser.logoutCurrentUser { (error) in
            if error == nil {
                print("logged out")
                self.navigationController?.popViewController(animated: true)
            }
            else {
                print("error log out", error!.localizedDescription)
            }
        }
    }
}
