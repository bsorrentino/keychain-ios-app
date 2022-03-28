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

extension SharedModule {
    
    public static func getPersistentContainer() throws -> NSPersistentContainer  {
        let container:NSPersistentContainer
        
        let objectModelName = "KeyChain"
        
        guard let objectModelUrl = Bundle.module.url(forResource: objectModelName, withExtension: "momd") else {
            // fatalError( "model '\(objectModelName)' not found!")
            throw "model '\(objectModelName)' not found!"
        }
        
        guard let dataModel = NSManagedObjectModel( contentsOf: objectModelUrl) else {
            // fatalError("error creating objevt model from url '\(objectModelUrl)'!")
            throw "error creating objevt model from url '\(objectModelUrl)'!"
        }
        
        if isInPreviewMode {
            container = NSPersistentContainer(name: objectModelName, managedObjectModel: dataModel)
        }
        else {
            container = NSPersistentCloudKitContainer(name: objectModelName, managedObjectModel: dataModel)
        }

        return container
    }
    
    
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
    public static func deleteAllWithMerge( context:NSManagedObjectContext ) throws {

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: KeyEntity.fetchRequest())
        
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        let result = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
        
        let objectIDs = result.result as! [NSManagedObjectID]
        
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
        
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }


}


