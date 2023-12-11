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

#if __COREDATA
enum SavingError :Error {
    
    case KeyDoesNotExist( id:String )
    case DuplicateKey( id:String )
    case InvalidItem( id:String )
    case BundleIdentifierUndefined
}


public final class CoreDataManager {
    let container: NSPersistentContainer
    
    public var context:NSManagedObjectContext {
        get {
            self.container.viewContext
        }
    }
    
    public init() {
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let _container:NSPersistentContainer
        
        let objectModelName = "KeyChain"
        
        guard let objectModelUrl = Bundle.module.url(forResource: objectModelName, withExtension: "momd") else {
//                throw "model '\(objectModelName)' not found!"
            fatalError( "model '\(objectModelName)' not found!")
        }
            
        guard let dataModel = NSManagedObjectModel( contentsOf: objectModelUrl) else {
//                throw "error creating objevt model from url '\(objectModelUrl)'!"
            fatalError("error creating objevt model from url '\(objectModelUrl)'!")
        }
        
        if isInPreviewMode {
            _container = NSPersistentContainer(name: objectModelName, managedObjectModel: dataModel)
            
            // set in memory
            _container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            _container.persistentStoreDescriptions.first!.type = NSInMemoryStoreType
        }
        else {
            _container = NSPersistentCloudKitContainer(name: objectModelName, managedObjectModel: dataModel)
//            _container = NSPersistentCloudKitContainer(name: objectModelName )
//            if let description = _container.persistentStoreDescriptions.first {
//                description.url = objectModelUrl
//                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//            }

        }

//        let description = NSPersistentStoreDescription()
//        description.shouldMigrateStoreAutomatically = true
//        description.shouldInferMappingModelAutomatically = true
//
//        if( container.persistentStoreDescriptions.isEmpty) {
//            container.persistentStoreDescriptions = [description]
//        }
//        else {
//            container.persistentStoreDescriptions.append(description)
//        }

        
        _container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        _container.viewContext.automaticallyMergesChangesFromParent = true

        
        //let container = NSPersistentContainer(name: "KeyChain")
        _container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
                //logger.critical( "Unresolved error \(error), \(error.userInfo)" )
            }
            
            logger.info(
                    """
                    
                    =================================================
                    DB url:
                    \(storeDescription.url?.absoluteString)
                    ------------------------------------------------
                    Data Model version:
                    \(_container.persistentStoreCoordinator.managedObjectModel.versionIdentifiers)
                    ------------------------------------------------
                    shouldMigrateStoreAutomatically: \(storeDescription.shouldMigrateStoreAutomatically)
                    ------------------------------------------------
                    shouldInferMappingModelAutomatically: \(storeDescription.shouldInferMappingModelAutomatically),
                    =================================================
                    
                    """
            )
            
        }
        self.container = _container
        
        if isInPreviewMode {
            self.createSimpleData()
        }
            
    }
    
}

extension CoreDataManager {
    
    func createSimpleData() {
        [
            "A0",
            "B0",
            "C0",
            "B1",
            "B2",
        ].forEach {
            let record = KeyEntity(context: container.viewContext)
            record.username = "bartolomeo.sorrentino@soulsoftware.it"
            record.mnemonic = $0
            
            container.viewContext.insert( record )
        }
        
        
        Dictionary( grouping: [
            "AG0-A0",
            "AG0-B0",
            "AG0-C0",
            "AG0-B1",
            "AG0-B2",
            "BG0-A0",
            "BG0-B0",
            "BG0-C0",
            "BG0-B1",
            "BG0-B2",
        ], by: { String($0[..<$0.index( $0.startIndex, offsetBy: 3 )]) })
        .forEach { keyValue in
            let record = KeyEntity(context: container.viewContext)
            record.mnemonic = keyValue.key
            record.groupPrefix = keyValue.key
            record.group = false
            container.viewContext.insert( record )
            
            keyValue.value.forEach { value in
                let record = KeyEntity(context: container.viewContext)
                //                if( value.hasSuffix("A0")) {
                //                    record.preferred = true
                //                }
                record.preferred = true
                record.username = value
                record.mnemonic = value
                record.group = true
                record.groupPrefix = keyValue.key
                
                container.viewContext.insert( record )
            }
            
        }
    }
    
}

// MARK: CoreData extension

extension SharedModule {
    
    // MARK: Fetch Single Value
    public static func fetchSingle<T : NSManagedObject>(
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
    public static func fetchSingleIfPresent<T : NSManagedObject>(
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

#endif
