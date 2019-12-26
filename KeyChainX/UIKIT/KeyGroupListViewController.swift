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
struct KeyGroupList: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = KeyGroupListViewController

    @Environment(\.managedObjectContext) var managedObjectContext
    var selectedGroup:KeyEntity
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<KeyGroupList>) -> UIViewControllerType
    {
        let controller =  KeyGroupListViewController(context: managedObjectContext, selectedGroup: selectedGroup)

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<KeyGroupList>) {

        uiViewController.reloadData()
    }
}

// MARK: UIKIT

class KeyGroupListViewController : UITableViewController {
    
    private var keys:[KeyEntity]?
    
    private var managedObjectContext: NSManagedObjectContext
    
    private var selectedGroup:KeyEntity
    
    init( context:NSManagedObjectContext, selectedGroup:KeyEntity  ) {
        self.selectedGroup = selectedGroup
        self.managedObjectContext = context
        super.init( style: .plain )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "KeyItemCell", bundle: nil), forCellReuseIdentifier: "keyitem")
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = self.keys else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "keyitem", for: indexPath)
        
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
    
//    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//
//        guard let keys = self.keys, let index = tableView.indexPathForSelectedRow?.row else {
//            return
//        }
//
//        let selectedItem = keys[index]
//
//        let newViewController = KeyEntityForm( entity: selectedItem )
//
//        self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)
//
//    }
    
    
    //
    // MARK: SWIPE ACTIONS
    //
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let keys = self.keys else {
            return nil
        }

        let selectedItem = keys[indexPath.row]

        let ungroup = UIContextualAction( style: .destructive, title: "ungroup" ) { action, view, completionHandler in
            self.performUngroup( item: selectedItem, completionHandler: completionHandler)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [ ungroup ])
        
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let keys = self.keys else {
            return nil
        }

        let selectedItem = keys[indexPath.row]


        let delete = UIContextualAction( style: .destructive, title: "Delete" ) { action, view, completionHandler in
            self.performDelete( item: selectedItem, completionHandler: completionHandler)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        
        return configuration
    }

}

// MARK: Custom Action(s)
extension KeyGroupListViewController  {
    
    func reloadData() {
        
        reloadDataFromManagedObjectContext()
    }
    
    func performDelete( item:KeyEntity, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Delete key",
                                                message:"Are you sure ?",
                                                preferredStyle: .alert)
        
        let yes = UIAlertAction(title:"Yes", style: .destructive ) { action in
           let result = self.delete(item: item)
           
           if( result ) {
               self.reloadData()
           }
           completionHandler(result)
        }
        alert.addAction(yes)
        alert.addAction(UIAlertAction(title:"No", style: .cancel, handler: nil))

        
        self.present(alert, animated: true)

    }
    
    func performUngroup( item:KeyEntity, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Ungroup key",
                                                message:"Are you sure ?",
                                                preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Yes", style: .destructive ) { action in
            let result = self.ungroup(item: item)
            
            if( result ) {
                self.reloadData()
            }
            completionHandler(result)
        })
        alert.addAction(UIAlertAction(title:"No", style: .cancel, handler: nil))

        
        self.present(alert, animated: true)

    }

}

// MARK: Core Data Extension
extension KeyGroupListViewController  {
    
    func ungroup( item:KeyEntity ) -> Bool{

        do {
            item.groupPrefix = nil
            item.group = NSNumber(booleanLiteral: false)

            try self.managedObjectContext.save()
            
            return true
        }
        catch {
            print( "error ungrouping  key \(error)" )
            return false
        }

    }
    
    func delete( item:KeyEntity ) -> Bool {

        do {
            self.managedObjectContext.delete(item)

            try self.managedObjectContext.save()
            
            return true
        }
        catch {
            print( "error deleting key \(error)" )
            return false
        }

    }

    
    func reloadDataFromManagedObjectContext()  {
        
        guard let groupPrefix = selectedGroup.groupPrefix else {
            print( "illegal argument")
            return
        }
        
        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true)
        
        request.sortDescriptors = [sortOrder]

        request.predicate = NSPredicate(  format: "groupPrefix = %@ AND group = YES", groupPrefix )

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



