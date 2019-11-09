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
import CoreData

// MARK: SwiftUI Bidge
struct KeyItemList: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = KeyItemListViewController
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<KeyItemList>) -> UIViewControllerType
    {
        print( "makeUIViewController" )
        
        let controller =  KeyItemListViewController(context: managedObjectContext)
        
        //controller.reloadData()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<KeyItemList>) {
        
        print( "updateUIViewController" )
        
        uiViewController.reloadData()
    }
}

// MARK: UIKIT

class KeyItemListViewController : UITableViewController {
    
    private var resultSearchController:UISearchController?
    
    private var allkeys:[KeyEntity]?
    private var filteredKeys:[KeyEntity]?

    private var keys:[KeyEntity]? {
        get {
            return isFiltering ? filteredKeys : allkeys
        }
        set {
            if isFiltering {
                filteredKeys = newValue
            }
            else {
                allkeys = newValue
            }
        }
    }
    
    private var managedObjectContext: NSManagedObjectContext
    
    private let searchController = UISearchController(searchResultsController: nil)

    init( context:NSManagedObjectContext ) {
        self.managedObjectContext = context
        super.init( style: .grouped )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        
        reloadDataFromManagedObjectContext( predicate:searchPredicate() )
    }
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "KeyItemCell", bundle: nil), forCellReuseIdentifier: "keyitem")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false   
        // Search Bar
        searchController.searchBar.placeholder = "search keys"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = tableView.backgroundColor
        
        tableView.tableHeaderView = searchController.searchBar
        
        resultSearchController = searchController
        
    }
    
    //
    // MARK: DATA SOURCE
    //

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print( "item at indexpath \(indexPath.row)" )
        
        guard let items = self.keys else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "keyitem", for: indexPath)
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.mnemonic.uppercased()
        cell.detailTextLabel?.text = item.isGrouped() ? item.groupPrefix ?? "" : item.username
        
        return cell
        
    }
    
    
    //
    // MARK: TAP ACTIONS
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let keys = self.keys, let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        let selectedItem = keys[index]
        
        let newViewController = KeyEntityForm( entity: selectedItem )
        self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let keys = self.keys, let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        let selectedItem = keys[index]
        
        let newViewController = KeyEntityForm( entity: selectedItem )
        
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

        guard let keys = self.keys else {
            return nil
        }

        let selectedItem = keys[indexPath.row]


        let delete = UIContextualAction( style: .destructive, title: "Delete" ) { action, view, completionHandler in

            self.delete(item: selectedItem)
            
            
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        
        return configuration
    }
    
    
}


let SEARCHTEXT_CRITERIA = "(mnemonic BEGINSWITH %@ OR mnemonic BEGINSWITH %@)"

// MARK: Search Extension
extension KeyItemListViewController : UISearchResultsUpdating {
  
    // create the Predicate coherent with UI state
    func searchPredicate() -> NSPredicate? {
        
        if searchController.isActive , let searchText = searchController.searchBar.text, !searchText.isEmpty {
            return NSPredicate(format: SEARCHTEXT_CRITERIA, searchText, searchText.uppercased())
        }
        
        return nil

    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        print( "updateSearchResults\nisActive:\(searchController.isActive)\nisFiltering:\(isFiltering)" )
        reloadDataFromManagedObjectContext( predicate: searchPredicate() )
        
    }
    
    
}

// MARK: Core Data Extension
extension KeyItemListViewController  {
    
    func delete( item:KeyEntity ) {

        self.managedObjectContext.delete(item)

        do {
            try self.managedObjectContext.save()
        }
        catch {
            print( "error deleting new key \(error)" )
        }

    }

    
    func reloadDataFromManagedObjectContext( predicate:NSPredicate? )  {
        
        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true)
        
        request.sortDescriptors = [sortOrder]
        
        request.predicate = predicate

        do {
            
            let result = try self.managedObjectContext.fetch(request)
            self.keys = result

        }
        catch {
            print( "error fetching keys \(error)" )
            self.keys = []
        }

        tableView.reloadData()
    }
    
}


