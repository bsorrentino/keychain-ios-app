//
//  AppDelegate+CoreData.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/03/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData
import Shared

// MARK: AppDelegate extension
extension AppDelegate {

    // MARK: Core Data Saving support
    internal func saveContext () {
        let context = self.manager.context

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func startObservingManagedObjectContextObjectsDidChangeEvent() {
        // Add Observer
        let objectContextObjectsDidChangeEvent = NSNotification.Name.NSManagedObjectContextObjectsDidChange
        
        let _ = NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange),
                                               name: objectContextObjectsDidChangeEvent,
                                               object: self.manager.context)
     
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
    }

    func stopObservingManagegObjectContextObjectsDidChangeEvent() {
        
    }

    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            logger.trace( "object inserted # \(inserts.count)" )
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            logger.trace( "object updated # \(updates.count)" )
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            logger.trace( "object deleted # \(deletes.count)" )
            
            for object in deletes {
                
                guard let keyDeleted = object as? KeyEntity else {
                    logger.trace( "object \(object) is not a KeyEntity")
                    continue
                }
                
                do {
                    if(  SharedModule.sharedSecrets.containsSecret(withKey: keyDeleted.mnemonic ) ) {
                        try SharedModule.sharedSecrets.removeSecret(key: keyDeleted.mnemonic )
                        logger.info( "shared secret \(keyDeleted.mnemonic) removed!")
                    }
                    else if( SharedModule.appSecrets.containsSecret(withKey: keyDeleted.mnemonic ) ){
                        try SharedModule.appSecrets.removeSecret(key: keyDeleted.mnemonic )
                        logger.info( "local secret \(keyDeleted.mnemonic) removed!")
                    }
                }
                catch {
                    logger.warning( "error removing password from entity \(keyDeleted)\n\(error.localizedDescription)" )
                }
            }
        }
    }
        
    

}
