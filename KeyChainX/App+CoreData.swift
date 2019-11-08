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

// MARK: CoreData MailEntity Extension
extension MailEntity {
    
    static func fetchAllMail() -> NSFetchRequest<MailEntity> {
        
        let request:NSFetchRequest<MailEntity> = MailEntity.fetchRequest()
        
        let sortOrder = NSSortDescriptor(keyPath: \MailEntity.value, ascending: true)
        
        request.sortDescriptors = [sortOrder]
        
        return request
        
    }
}
// MARK: CoreData KeyEntity Extension
extension KeyEntity {
    
    func toKeyItem() throws -> KeyItem {
        
        guard let id = self.mnemonic, let username = self.username else {
            throw "Invalid KeyEntity no mnemonic or username defined"
        }
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw "Bundle Identifier Undefined"
        }
        
        let keychain = Keychain(service: bundleIdentifier).accessibility(.whenUnlocked)

        
        guard let password = try keychain.get(id) else {
            //throw "password doesn't found for key \(id)"
            return KeyItem( id:id, username:username, password:Keychain.generatePassword() )
        }
        
        return KeyItem( id:id, username:username, password:password )
    }

    
    func from( item: KeyItem ) -> KeyEntity {
        self.mnemonic = item.id
        self.username = item.username
        return self
    }

    static func fromKeyItem( item: KeyItem, context:NSManagedObjectContext ) throws -> KeyEntity {
        
        let result = KeyEntity( context:context )

        return result.from( item:item )
    }

}

extension KeyItem  {
    /**
        Fetch KeyItem by id
     */
    func fetchKeyItemById( _ context:NSManagedObjectContext, item:KeyItem ) throws -> KeyEntity {
        
        guard let result = try fetchSingle( context,
                                            entity:KeyEntity.entity(),
                                            predicateFormat:"(mnemonic = %@)",
                                            key:item.id) as? KeyEntity else {
                throw SavingError.InvalidItem(id: item.id)
        }
        return result

    }

    func save( _ context:NSManagedObjectContext ) throws {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw SavingError.BundleIdentifierUndefined
        }
        
        let keychain = Keychain(service: bundleIdentifier).accessibility(.whenUnlocked)

        switch( state ) {
        case .new:
            let record = try KeyEntity.fromKeyItem(item: self, context: context)
            context.insert( record )
            try keychain.set(self.password, key: self.id)
            state = .neutral
            break
        case .updated:
            let result = try self.fetchKeyItemById( context, item:self )
            let _ = result.from(item: self)
            try keychain.set(self.password, key: self.id)
            state = .neutral
            break
        case .deleted:
            let result = try self.fetchKeyItemById( context, item:self )
            let _ = result.from(item: self)
            context.delete(result)
            try keychain.remove(self.id)
            break
        default:
            break
        }

    }
}

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

extension AppDelegate {
    
    

}


extension SceneDelegate {
    
    var  managedObjectContext:NSManagedObjectContext {        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("Unable to read managed object context.")
        }
        return context
    }

}

