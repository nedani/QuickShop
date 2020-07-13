//
//  PurchasedHistoryTableViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PurchasedHistoryTableViewController: UITableViewController {
    
    var itemArray : [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadItems()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell

        cell.generateItem(itemArray[indexPath.row])

        return cell
    }
    //MARK:- load items
    private func loadItems() {
        
        downloadItems(MUser.currentUser()!.purchasedItemsIds) { (allItems) in
            
            self.itemArray = allItems
            print("we have \(allItems.count) purchased items")
            self.tableView.reloadData()
        }
    }
}

//MARK:- emptyDataset methods

    extension PurchasedHistoryTableViewController : EmptyDataSetSource, EmptyDataSetDelegate  {
        
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
