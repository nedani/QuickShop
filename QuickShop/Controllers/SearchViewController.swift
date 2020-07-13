//
//  SearchViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-30.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    var searchResult: [Item] = []
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK:- lifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballSpinFadeLoader, color: UIColor.init(named: "color-blue"), padding: nil)
    }
    
    //MARK:- IBActions
    
    @IBAction func showSearchBtnPressed(_ sender: UIBarButtonItem) {
        
        dismissKeyBoard()
        showSearchField()
    }
    
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        
        if searchTextField.text != "" {
            
            //search
            searchInFirebase(forName: searchTextField.text!)
            emptyTextField()
            animateSearchOption()
            dismissKeyBoard()
            
        }
    }
    
    //MARK:- search database
    private func searchInFirebase(forName: String) {
        
        showLoadingIndicator()
        searchAlgolia(searchString: forName) { (itemIds) in
            
            downloadItems(itemIds) { (allItems) in
                self.searchResult = allItems
                self.tableView.reloadData()
                
                self.hideLoadingIndicator()
            }
        }
    }
    
    //MARK:- helpers
    
    private func emptyTextField() {
        
        searchTextField.text = ""
    }
    
    private func dismissKeyBoard() {
        self.view.endEditing(false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        searchBtn.isEnabled = textField.text != ""
        
        if searchBtn.isEnabled {
            searchBtn.backgroundColor = UIColor(named: "color-blue")
        }
        else {
            disableSearchBtn()
        }
    }
    
    private func disableSearchBtn() {
        
        searchBtn.isEnabled = false
        searchBtn.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    private func showSearchField() {
        
        disableSearchBtn()
        emptyTextField()
        animateSearchOption()
    }
 //MARK:- Animations
    private func animateSearchOption() {
        
        UIView.animate(withDuration: 0.5) {
            self.searchView.isHidden = !self.searchView.isHidden
        }
    }
   //MARK:- activity Indicator
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.startAnimating()
        }
    }
    
    private func showItemView(withItem: Item) {
        
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
        
    }
}
//MARK:- tableView delegate methods
extension SearchViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateItem(searchResult[indexPath.row])
        
        return cell
    }
    
    //MARK:- UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: searchResult[indexPath.row])
    }
    
}

//MARK:- emptyDataset methods

    extension SearchViewController : EmptyDataSetSource, EmptyDataSetDelegate  {
        
        func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
            
            return NSAttributedString(string: "No items to display!")
        }
        
        func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
            
            return UIImage(named: "emptyData")
        }
        
        func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
            
            return NSAttributedString(string: "Please check back later")
        }
        
        func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
            return UIImage(named: "search")
        }
        
        func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
            
            return NSAttributedString(string: "Start searching...")
        }
        
        func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
            
            showSearchField()
        }
}
