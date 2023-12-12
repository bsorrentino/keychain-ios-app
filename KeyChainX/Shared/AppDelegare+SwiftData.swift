//
//  AppDelegare+SwiftData.swift
//  KeyChainX
//
//  Created by bsorrentino on 12/12/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData
import Shared

// MARK: AppDelegate extension
extension AppDelegate {
    
    func startObservingManagedObjectContextObjectsDidChangeEvent() {
        // Add Observer
        let objectContextObjectsDidChangeEvent = NSNotification.Name.NSManagedObjectContextObjectsDidChange
        
        let _ = NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange),
                                               name: objectContextObjectsDidChangeEvent,
                                               object: nil)
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
            
//            for object in deletes {
//                
//                guard let keyDeleted = object as? KeyInfo else {
//                    logger.trace( "object \(object) is not a KeyEntity")
//                    continue
//                }
//                
//                do {
//                    if(  SharedModule.sharedSecrets.containsSecret(withKey: keyDeleted.mnemonic ) ) {
//                        try SharedModule.sharedSecrets.removeSecret(key: keyDeleted.mnemonic )
//                        logger.info( "shared secret \(keyDeleted.mnemonic) removed!")
//                    }
//                    else if( SharedModule.appSecrets.containsSecret(withKey: keyDeleted.mnemonic ) ){
//                        try SharedModule.appSecrets.removeSecret(key: keyDeleted.mnemonic )
//                        logger.info( "local secret \(keyDeleted.mnemonic) removed!")
//                    }
//                }
//                catch {
//                    logger.warning( "error removing password from entity \(keyDeleted)\n\(error.localizedDescription)" )
//                }
//            }
        }
    }
        
    

}

