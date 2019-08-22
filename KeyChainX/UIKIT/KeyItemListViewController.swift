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
    
    var keys:ApplicationKeys?
    
    private var cellView:ViewProvider?
    
    private var resultSearchController:UISearchController?
    
    private var viewItems:[KeyItem]?
    
    func reloadData() {
        self.viewItems = keys?.items.filter{ item -> Bool in
            return item.state != .deleted
        }
        tableView.reloadData()
    }
    
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
        //print( "items.count: \(items?.count ?? 0)")
        return viewItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print( "item at indexpath \(indexPath.row)" )
        
        guard let items = self.viewItems else {
            return UITableViewCell()
        }
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
        
        guard let items = self.viewItems, let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        let selectedItem = items[index]
        
        let newViewController = KeyItemForm( item: selectedItem )
        self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let items = self.viewItems, let index = tableView.indexPathForSelectedRow?.row else {
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

        guard let items = self.viewItems else {
            return nil
        }

        let selectedItem = items[indexPath.row]


        let delete = UIContextualAction( style: .destructive, title: "Delete" ) { action, view, completionHandler in
                
            selectedItem.state = .deleted
            self.reloadData()
            self.keys?.objectWillChange.send( selectedItem )
            
            
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        
        return configuration
    }
    
    
}

extension KeyItemListViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}

