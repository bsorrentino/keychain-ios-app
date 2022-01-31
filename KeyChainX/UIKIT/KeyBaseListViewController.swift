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

typealias FormSupplierType = ( KeyEntity ) -> KeyEntityForm

// MARK: GROUP CELL

class GroupTableViewCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
}

// MARK: BASE LIST VIEW CONTROLLER

class KeyBaseListViewController : UIViewController, UITableViewDelegate {
    
    internal var managedObjectContext: NSManagedObjectContext

    internal var tableView:UITableView

    var provideFormOnSelection:FormSupplierType

    init( context:NSManagedObjectContext, frame tableViewFrame:CGRect = .zero, style: UITableView.Style = .plain, provideFormOnSelection:@escaping FormSupplierType) {
        
        self.managedObjectContext = context
        self.provideFormOnSelection = provideFormOnSelection
        self.tableView = UITableView(frame: tableViewFrame, style: style)

        super.init( nibName: nil, bundle: nil )
        
        self.tableView.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyContentInsets( _ contentInsets: UIEdgeInsets ) {
        
        //self.edgesForExtendedLayout = UIRectEdge()
        //self.extendedLayoutIncludesOpaqueBars = false
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        //self.tableView.contentInsetAdjustmentBehavior = .always

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = self.view.frame.height

        self.tableView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        self.view.addSubview(self.tableView)
        
    }
    
    // MUST BE OVERRIDE
    func reloadData() { fatalError("not implemented") }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            logger.warning( "error ungrouping  key \(error.localizedDescription)" )
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
            logger.warning( "error deleting key \(error.localizedDescription)" )
            return false
        }

    }

    
}
