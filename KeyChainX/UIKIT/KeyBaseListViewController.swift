//
//  KeyBaseListViewController.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 27/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class KeyBaseListViewController : UITableViewController {
    
    internal var managedObjectContext: NSManagedObjectContext

    init( context:NSManagedObjectContext ) {
        self.managedObjectContext = context
        super.init( style: .grouped )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData() { fatalError("not implemented") }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    

}

// MARK: Custom Action(s)
extension KeyBaseListViewController  {
    
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
extension KeyBaseListViewController  {
    
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

    
}
