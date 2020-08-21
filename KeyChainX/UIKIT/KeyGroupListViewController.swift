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
    
    var contentInsets:UIEdgeInsets?;
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<KeyGroupList>) -> UIViewControllerType
    {
        let controller =  KeyGroupListViewController(context: managedObjectContext, selectedGroup: selectedGroup)

        controller.contentInsets = contentInsets
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<KeyGroupList>) {

        uiViewController.reloadData()
    }
}

// MARK: UIKIT

class KeyGroupListViewController : KeyBaseListViewController, UITableViewDataSource {
    
    private var keys:[KeyEntity]?
    
    private var selectedGroup:KeyEntity
    
    var contentInsets:UIEdgeInsets?
    
    init( context:NSManagedObjectContext, selectedGroup:KeyEntity  ) {
        self.selectedGroup = selectedGroup
        super.init( context:context )
        
        self.tableView.dataSource = self

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        
        reloadDataFromManagedObjectContext()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "KeyItemCell", bundle: nil), forCellReuseIdentifier: "keyitem")
        
        if let contentInsets = self.contentInsets {
            
            print( contentInsets )

            applyContentInsets(contentInsets)
        }
    }
        
    //
    // MARK: DATA SOURCE
    //

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        guard let keys = self.keys else {
//            return nil
//        }
//
//        let selectedItem = keys[indexPath.row]
//
//        let ungroup = UIContextualAction( style: .destructive, title: "ungroup" ) { action, view, completionHandler in
//            self.performUngroup( item: selectedItem, completionHandler: completionHandler)
//        }
//
//        let configuration = UISwipeActionsConfiguration(actions: [ ungroup ])
//
//        configuration.performsFirstActionWithFullSwipe = true
//        return configuration
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let keys = self.keys else {
            return nil
        }

        let selectedItem = keys[indexPath.row]


        let delete = UIContextualAction( style: .destructive, title: "delete" ) { action, view, completionHandler in
            self.performDelete( item: selectedItem, completionHandler: completionHandler)
        }

        let ungroup = UIContextualAction( style: .normal, title: "ungroup" ) { action, view, completionHandler in
            self.performUngroup( item: selectedItem, completionHandler: completionHandler)
        }
        ungroup.backgroundColor = UIColor.blue

        let configuration = UISwipeActionsConfiguration(actions: [ungroup, delete])
        
        return configuration
    }

}


// MARK: Core Data Extension
extension KeyGroupListViewController  {
    
    
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



