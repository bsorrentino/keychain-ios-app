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
        
        controller.reloadData()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<KeyItemList>) {
        
        uiViewController.reloadData()
    }
}

// MARK: UIKIT

class KeyItemListViewController : UITableViewController {
    
    private var resultSearchController:UISearchController?
    
    private var items:[KeyEntity]?
    
    private var managedObjectContext: NSManagedObjectContext
    
    init( context:NSManagedObjectContext ) {
        self.managedObjectContext = context
        super.init( style: .grouped )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        fetchKeysByPredicate()
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
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print( "item at indexpath \(indexPath.row)" )
        
        guard let items = self.items else {
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
        
        guard let items = self.items, let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        let selectedItem = items[index]
        
        let newViewController = KeyItemForm( item: selectedItem )
        self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let items = self.items, let index = tableView.indexPathForSelectedRow?.row else {
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

        guard let items = self.items else {
            return nil
        }

        let selectedItem = items[indexPath.row]


        let delete = UIContextualAction( style: .destructive, title: "Delete" ) { action, view, completionHandler in

            self.delete(item: selectedItem)
            self.reloadData()
            
            
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        
        return configuration
    }
    
    
}

// MARK: Search Extension
extension KeyItemListViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
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

    
    func fetchKeysByPredicate( _ predicate: NSPredicate? = nil )  {
        
        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true)
        
        request.sortDescriptors = [sortOrder]
        
        request.predicate = predicate

        do {
            let result = try self.managedObjectContext.fetch(request)
            self.items = result
         
        }
        catch {
            print( "error fetching keys \(error)" )
            self.items = []
        }
    }
    
}


