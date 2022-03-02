//
//  Shared+CoreData.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 29/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData
import OSLog

enum SavingError :Error {
    
    case KeyDoesNotExist( id:String )
    case DuplicateKey( id:String )
    case InvalidItem( id:String )
    case BundleIdentifierUndefined
}


// MARK: CoreData extension

extension Shared {
    
    // MARK: Fetch Single Value
    static func fetchSingle<T : NSManagedObject>(
        context:NSManagedObjectContext,
        entity:NSEntityDescription,
        predicateFormat:String,
        key:String  ) throws -> T
    {

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity =  entity
        request.predicate = NSPredicate( format: predicateFormat, key)
        let fetchResult = try context.fetch( request )
        
        if( fetchResult.count == 0 ) {
            throw SavingError.KeyDoesNotExist(id: key)
            
        }
        if( fetchResult.count > 1 ) {
            throw SavingError.DuplicateKey(id: key)
            
        }
        return fetchResult.first as! T
    }
    
    // MARK: Fetch Single Value if Present
    static func fetchSingleIfPresent<T : NSManagedObject>(
        context:NSManagedObjectContext,
        entity:NSEntityDescription,
        predicateFormat:String,
        key:String  ) throws -> T?
    {

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity =  entity
        request.predicate = NSPredicate( format: predicateFormat, key)
        let fetchResult = try context.fetch( request )
        
        if( fetchResult.count == 0 ) {
            return nil
        }
        if( fetchResult.count > 1 ) {
            throw SavingError.DuplicateKey(id: key)
            
        }
        return fetchResult.first as? T
    }

//    func deleteAll() throws -> Int {
//        let context = managedObjectContext
//
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: KeyEntity.fetchRequest())
//
//        batchDeleteRequest.resultType = .resultTypeCount
//
//        let result = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
//
//        return result.result as! Int
//    }

    //
    // @see https://www.avanderlee.com/swift/nsbatchdeleterequest-core-data/
    //
    static func deleteAllWithMerge( context:NSManagedObjectContext ) throws {

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: KeyEntity.fetchRequest())
        
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        let result = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
        
        let objectIDs = result.result as! [NSManagedObjectID]
        
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
        
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }


}


// MARK: AppDelegate extension
extension AppDelegate {
    
    var  managedObjectContext:NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    // MARK: Core Data Saving support
    internal func saveContext () {
        let context = managedObjectContext

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
                                               object: managedObjectContext)
     
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
                    logger.trace( "obejct \(object) is not a KeyEntity")
                    continue
                }
                
                do {
                    try Shared.appSecrets.removeSecret(key: keyDeleted.mnemonic )
                    logger.trace( "secrets \(keyDeleted.mnemonic) removed!")
                }
                catch {
                    logger.warning( "error removing password from entity \(keyDeleted)\n\(error.localizedDescription)" )
                }
            }
        }
    }
        
    

}
