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


// MARK: CoreData extension

enum SavingError :Error {
    
    case KeyDoesNotExist( id:String )
    case DuplicateKey( id:String )
    case InvalidItem( id:String )
    case BundleIdentifierUndefined
}


/**
    Fetch Single Value
 */
func fetchSingle( _ context:NSManagedObjectContext, entity:NSEntityDescription, predicateFormat:String, key:String  ) throws -> Any {

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



extension SceneDelegate {
    
    var  managedObjectContext:NSManagedObjectContext {        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("Unable to read managed object context.")
        }
        return context
    }

}

