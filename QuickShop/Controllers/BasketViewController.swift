//
//  BasketViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import JGProgressHUD
import Stripe
import NVActivityIndicatorView

class BasketViewController: UIViewController{

    
    
    @IBOutlet weak var totalItems: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var basket : Basket?
    var allItems: [Item] = []
    var purchasedItemIds: [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    var totalPrice = 0
    
    //MARK:- lifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //check if user is logged In
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        }
        else{
            self.updateTotalLabel(true)
        }
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballSpinFadeLoader, color: UIColor.init(named: "color-blue"), padding: nil)
    }
    
    @IBAction func checkoutPressed(_ sender: UIButton) {
        
        if MUser.currentUser()!.onBoard {

            //show action sheet
            showPaymentOptions()

        } else {
            self.showNotification(text: "Please complete your profile!", isError: true)
        }
    }
    
    //MARK:- download basket
    private func loadBasketFromFirestore() {
        
        downloadBasketFromFirestore(MUser.currentId()) { (basket) in
            
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems() {
        
        if basket != nil {
            
            downloadItems(basket!.itemIds) { (allItems) in
                
                self.allItems = allItems
                self.updateTotalLabel(false)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK:- helper functions
    private func updateTotalLabel(_ isEmpty: Bool) {
        
        if isEmpty {
            totalItems.text = "0"
            totalPriceLbl.text = calculateTotalPrice()
        }
        else {
            totalItems.text = "\(allItems.count)"
            totalPriceLbl.text = calculateTotalPrice()
        }
        checkoutBtnStatus()
    }
    
    private func calculateTotalPrice() -> String {
        
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        return "Total price: " + converToCurrency(totalPrice)
    }
    
    private func emptyTheBasket() {
        
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        updateBasketInFirestore(basket!, withValues: [Constants.K.basket.itemIds : basket!.itemIds]) { (error) in
            
            if error != nil {
                print("Error Updating basket", error!.localizedDescription)
            }
            self.getBasketItems()
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        
        if MUser.currentUser() != nil {
            let newItemIds = MUser.currentUser()!.purchasedItemsIds + itemIds
            updateUserInFirestore(withValues: [Constants.K.user.purchasedItems : newItemIds]) { (error) in
                
                if error != nil {
                    print("error adding purchased items", error!.localizedDescription)
                }
            }
        }
    }
    //MARK:- control checkout button
    private func checkoutBtnStatus() {
        
        checkOutButton.isEnabled = allItems.count > 0
        
        if checkOutButton.isEnabled {
            checkOutButton.backgroundColor = UIColor.init(named: "color-lightBlue")
        }
        else {
            disableCheckoutBtn()
        }
    }
    
    private func disableCheckoutBtn() {
        
        checkOutButton.isEnabled = false
        checkOutButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    private func removeItemfromBasket(itemId: String) {
        
        for i in 0..<basket!.itemIds.count {
            
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }
    
    private func payButtonPressed(token: STPToken) {
        
        self.totalPrice = 0
        
        showLoadingIndicator()
        for item in allItems {
            
            purchasedItemIds.append(item.id)
            self.totalPrice += Int(item.price)
        }
        //convert the amount to cent
        self.totalPrice = self.totalPrice * 100
        StripeClient.sharedClient.createAndConfirmPayment(token, amount: totalPrice) { (error) in
            
            if error != nil {
                self.showNotification(text: error!.localizedDescription, isError: true)
                
            }
            else {
                
                self.addItemsToPurchaseHistory(self.purchasedItemIds)
                self.emptyTheBasket()
                //show notification
                self.hideLoadingIndicator()
                self.showNotification(text: "Payment Successful!", isError: false)
            }
        }
        
    }
    
    private func showNotification(text: String, isError: Bool) {
        
        if isError {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        }
        else {
            self.hud.textLabel.text = text
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
        
    }
    
    private func showPaymentOptions() {
        
        let alertController = UIAlertController(title: "Payment Options", message: "Choose prefered payment option", preferredStyle: .actionSheet)
        
        let cardAction = UIAlertAction(title: "Pay with Card", style: .default) { (action) in
            //show card number view
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cardInfoVC") as! CardInfoViewController
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cardAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- navigation
    private func showitemView(withItem: Item) {
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    //MARK:- Activity Indicator
    
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }

    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
}
// MARK:- tableView delegate methods
extension BasketViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateItem(allItems[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            
            tableView.reloadData()
            
            removeItemfromBasket(itemId: itemToDelete.id)
            updateBasketInFirestore(basket!, withValues: [Constants.K.basket.itemIds: basket!.itemIds]) { (error) in
                
                if error != nil {
                    print("error updating to basket", error!.localizedDescription)
                }
                else {
                    self.getBasketItems()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showitemView(withItem: allItems[indexPath.row])
    }
}

//MARK:-
extension BasketViewController: CardInfoViewControllerDelegate {
    
    func didClickDone(_ token: STPToken) {
        
        payButtonPressed(token: token)
    }
    
    func didClickCancel() {
        
        showNotification(text: "Payment Canceled", isError: true)
    }
    
    
    
}
