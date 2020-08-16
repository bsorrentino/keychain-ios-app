//
//  App+CoreData.swift
//  KeyChainX
//
//  Created by softphone on 24/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import Combine
import KeychainAccess
import FieldValidatorLibrary

// MARK: Search Criterias

// MARK: CoreData extension

enum SavingError :Error {
    
    case KeyDoesNotExist( id:String )
    case DuplicateKey( id:String )
    case InvalidItem( id:String )
    case BundleIdentifierUndefined
}


extension UIApplication {
    
    var  managedObjectContext:NSManagedObjectContext {
        guard let context = (delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("Unable to read managed object context.")
        }
        return context
    }
    
    
    func managedObjectContextInit() {
        startObservingManagedObjectContextObjectsDidChangeEvent()
    }
    
    func managedObjectContextDestroy() {
        
        saveContext()
        stopObservingManagegObjectContextObjectsDidChangeEvent()
    }

    private func startObservingManagedObjectContextObjectsDidChangeEvent() {
        // Add Observer
        let objectContextObjectsDidChangeEvent = NSNotification.Name.NSManagedObjectContextObjectsDidChange
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange),
                                               name: objectContextObjectsDidChangeEvent,
                                               object: managedObjectContext)
     
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
    }

    private func stopObservingManagegObjectContextObjectsDidChangeEvent() {
            // Add Observer
            let objectContextObjectsDidChangeEvent = NSNotification.Name.NSManagedObjectContextObjectsDidChange
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(managedObjectContextObjectsDidChange),
                                                   name: objectContextObjectsDidChangeEvent,
                                                   object: managedObjectContext)
         
    //        notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
    //        notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
    }

    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print( "object inserted # \(inserts.count)" )
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print( "object updated # \(updates.count)" )
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print( "object deleted # \(deletes.count)" )
            
            for object in deletes {
                
                guard let keyDeleted = object as? KeyEntity else {
                    print( "obejct \(object) is not a KeyEntity")
                    continue
                }
                
                do {
                    try removeSecrets(key: keyDeleted.mnemonic )
                    print( "secrets \(keyDeleted.mnemonic) removed!")
                }
                catch {
                    print( "error removing password from entity \(keyDeleted)\n\(error)" )
                }
            }
        }
    }
        
    
    // Core Data Saving support
    private func saveContext () {
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

    /**
        Fetch Single Value
     */
    func fetchSingle( entity:NSEntityDescription, predicateFormat:String, key:String  ) throws -> Any {
        let context = managedObjectContext

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
        return fetchResult[0]
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
    func deleteAllWithMerge() throws {
        let context = managedObjectContext

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: KeyEntity.fetchRequest())
        
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        let result = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
        
        let objectIDs = result.result as! [NSManagedObjectID]
        
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
        
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }

    func backupData( to FileName:String ) throws {
        
        
    }




}

#if false
struct KeyItemPublisher : Combine.Publisher {
    typealias Output = KeyItem
    
    typealias Failure = Error
    
    var context:NSManagedObjectContext
    
    func receive<S>(subscriber: S) where S : Subscriber,
        KeyItemPublisher.Failure == S.Failure,
        KeyItemPublisher.Output == S.Input {
        
            subscriber.receive(subscription: Subscriptions.empty)
            
            do {
                let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
                
                let result = try context.fetch(request)

                try result.forEach { e in
                    
                    let item = try e.toKeyItem()
                    let _ = subscriber.receive(item)
                }
                
                subscriber.receive(completion: Subscribers.Completion.finished )
            }
            catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //let nserror = error as NSError
                //fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                subscriber.receive(completion: Subscribers.Completion.failure(error) )

            }
    }
    
}
#endif



