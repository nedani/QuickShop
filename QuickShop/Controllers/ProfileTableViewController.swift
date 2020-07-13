//
//  ProfileTableViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var finishRegisterBtn: UIButton!
    @IBOutlet weak var purchaseHistoryBtn: UIButton!
    
    var editBarBtn : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //remove empty cells of tablesView
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //check logged In status
        checkLoginStatus()
        checkOnBoardingStatus()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    //MARK:- tableview delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK:- helpers
    private func checkLoginStatus() {
        
        if MUser.currentUser() == nil {
            createRightBarBtn(title: "Login")
        }
        else {
            createRightBarBtn(title: "Edit")
        }
    }
    
    private func createRightBarBtn(title: String) {
        
        editBarBtn = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarBtnPressed))
        
        self.navigationItem.rightBarButtonItem = editBarBtn
    }
    
    @objc func rightBarBtnPressed() {
        
        if editBarBtn.title == "Login" {
            //show login view
            showLoginView()
        }
        else {
            //go to user profile
            goToProfile()
        }
    }
    
    private func showLoginView() {
        
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        loginView.modalPresentationStyle = .fullScreen
        self.present(loginView, animated: true, completion: nil)
    }
    
    private func goToProfile() {
        
        performSegue(withIdentifier: "profileToEdit", sender: self)
    }

    private func checkOnBoardingStatus() {
        
        if MUser.currentUser() != nil {
            if !MUser.currentUser()!.onBoard {
                finishRegisterBtn.setTitle("Finish registration", for: .normal)
                finishRegisterBtn.isEnabled = true
                finishRegisterBtn.tintColor = UIColor.init(named: "color-pink")
            }
            else{
                finishRegisterBtn.setTitle("Account is Active", for: .normal)
                finishRegisterBtn.isEnabled = false

            }
            
            purchaseHistoryBtn.isEnabled = true
        }
        else {
            finishRegisterBtn.setTitle("Logged out", for: .normal)
            finishRegisterBtn.isEnabled = false
            purchaseHistoryBtn.isEnabled = false
        
        }
    }
}
