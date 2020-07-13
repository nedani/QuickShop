//
//  ItemsTableViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-04.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class ItemsTableViewController: UITableViewController{
    
    
    var category : Category?
    var itemArray : [Item] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        self.title = category?.name
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadItems()
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateItem(itemArray[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItem(itemArray[indexPath.row])
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addItem" {
            let destination = segue.destination as! AddItemViewController
            destination.category = category!
        }
    }
    
    private func showItem(_ item: Item) {
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    //MARK:- loading
    func loadItems() {
        
        downloadItemFromFirebase(category!.id) { (items) in
            print(items.count)
            self.itemArray = items
            self.tableView.reloadData()
        }
    }
}

//MARK:- emptyDataset methods

    extension ItemsTableViewController : EmptyDataSetSource, EmptyDataSetDelegate  {
        
        func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
            
            return NSAttributedString(string: "No items to display!")
        }
        
        func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
            
            return UIImage(named: "emptyData")
        }
        
        func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
            
            return NSAttributedString(string: "Please check back later")
        }
}
