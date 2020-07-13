//
//  FinishRegistrationViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import JGProgressHUD


class FinishRegistrationViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneBtn.layer.cornerRadius = 5
        
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        
        finishOnboarding()
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        updateDoneBtnStatus()
    }
    
    //MARK:- helper
    private func updateDoneBtnStatus() {
        
        if nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "" {
            doneBtn.backgroundColor = UIColor.init(named: "color-blue")
            doneBtn.isEnabled = true
        }
        else {
            doneBtn.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            doneBtn.isEnabled = false
        }
    }
    
    private func finishOnboarding() {
        
        let withValues = [Constants.K.user.firstName: nameTextField.text!, Constants.K.user.lastName: surnameTextField.text!, Constants.K.user.onBoard : true, Constants.K.user.fullAddress: addressTextField.text!, Constants.K.user.fullName: (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
        
        updateUserInFirestore(withValues: withValues) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Updated!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print("error updating user \(error!.localizedDescription)")
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
}
