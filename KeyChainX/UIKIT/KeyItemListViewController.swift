//
//  KeyItemListViewController.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/07/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


class KeyItemListViewController : UITableViewController {
    
    
    var items:[KeyItem] = []
    
    var cellView:ViewProvider?
    
    var resultSearchController:UISearchController?
    
    override func viewDidLoad() {
        
        tableView.register(UINib(nibName: "KeyItemCell", bundle: nil), forCellReuseIdentifier: "keyitem")
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.barTintColor = tableView.backgroundColor
        
        tableView.tableHeaderView = searchController.searchBar
        
        resultSearchController = searchController
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "keyitem", for: indexPath)
        
        let item = items[indexPath.row]
        if let viewProvider = self.cellView {
            cell.contentView.addSubview(viewProvider(item))
        }
        
        cell.textLabel?.text = item.id.uppercased()
        cell.detailTextLabel?.text = item.grouped ? item.groupPrefix ?? "" : item.username
        
        return cell
        
    }
    
    
    //
    // MARK: TAP ACTIONS
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        let selectedItem = items[index]
        
        let newViewController = KeyItemForm( item: selectedItem )
        self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        let selectedItem = items[index]
        
        let newViewController = KeyItemForm( item: selectedItem )
        
        self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)
    }
    
    
    //
    // MARK: SWIPE ACTIONS
    //
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let copy = UIContextualAction( style: .normal, title: "Copy" ) { action, view, completionHandler in
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [ copy ])
        
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let configuration = UISwipeActionsConfiguration(actions: [])
        
        return configuration
    }
    
    
}

extension KeyItemListViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}

