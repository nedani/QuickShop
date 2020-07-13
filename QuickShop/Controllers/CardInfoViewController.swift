//
//  CardInfoViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-07-01.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import Stripe

protocol CardInfoViewControllerDelegate {
    func didClickDone(_ token: STPToken)
    func didClickCancel()
}


class CardInfoViewController: UIViewController {
    
    @IBOutlet weak var doneBtn: UIButton!
    
    let paymentCardTextField = STPPaymentCardTextField()
    var delegate : CardInfoViewControllerDelegate?
    
    //MARK:- lifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(paymentCardTextField)
        paymentCardTextField.delegate = self
        
        paymentCardTextField.translatesAutoresizingMaskIntoConstraints = false
        //top
        view.addConstraint(NSLayoutConstraint(item: paymentCardTextField, attribute: .top, relatedBy: .equal, toItem: doneBtn, attribute: .bottom, multiplier: 1, constant: 30) )
        //left side
        view.addConstraint(NSLayoutConstraint(item: paymentCardTextField, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20) )
        //right side
        view.addConstraint(NSLayoutConstraint(item: paymentCardTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20) )
        
    }
    //MARK:- IBActions
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        
        delegate?.didClickCancel()
        dismissView()
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        
        processCard()
    }
    
    //MARK:- helpers
    private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func processCard() {
        
        let cardParams = STPCardParams()
        cardParams.number = paymentCardTextField.cardNumber
        cardParams.expMonth = paymentCardTextField.expirationMonth
        cardParams.expYear = paymentCardTextField.expirationYear
        cardParams.cvc = paymentCardTextField.cvc
        
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            
            if error == nil {
                
                self.delegate?.didClickDone(token!)
                self.dismissView()
            }
            else {
                print("Error Processing card token",error!.localizedDescription)
            }
        }
    }
}

//MARK:- payment delegate
extension CardInfoViewController: STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        
        doneBtn.isEnabled = textField.isValid
        
    }
}
