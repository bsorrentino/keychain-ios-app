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

let IS_SECTION_CRITERIA = "(groupPrefix != nil AND (group == nil OR group == NO))"
let IS_GROUPED_CRITERIA = "(groupPrefix != nil AND group != nil AND group == YES)"
let SEARCHTEXT_CRITERIA = "(mnemonic BEGINSWITH %@ OR mnemonic BEGINSWITH %@)"



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

/**
 
 */
func fetchSections( _ context:NSManagedObjectContext  ) throws -> [KeyEntity] {

    let request = NSFetchRequest<NSFetchRequestResult>()
    request.entity =  KeyEntity.entity()
    request.predicate = NSPredicate( format: IS_SECTION_CRITERIA )
    let fetchResult = try context.fetch( request )
    
    return fetchResult as! [KeyEntity]
}

//
// MARK: DISCONNECTED KEYENTITY OBJECT
//

 
class KeyItem : ObservableObject {

    private var entity:KeyEntity?
    
    @Published var mnemonic: String
    @Published var username: String
    @Published var password: String
    @Published var mail: String
    @Published var note: String

    @Published var username_mail_setter: String = "" {
        didSet {
            username = username_mail_setter
            mail = username_mail_setter
        }
    }

    @Published var mnemonicCheck = FieldChecker()
    @Published var usernameCheck = FieldChecker()
    @Published var passwordCheck = FieldChecker()
    @Published var mailCheck = FieldChecker()
    @Published var noteCheck = FieldChecker()

    var isNew:Bool { return entity == nil  }

    var checkIsValid:Bool {
        return  mnemonicCheck.valid &&
                usernameCheck.valid &&
                passwordCheck.valid
    }
    
    init() {
        self.mnemonic = ""
        self.username = ""
        self.password = ""
        self.mail = ""
        self.note = ""
        
        self.entity = nil
    }
    
    init( entity: KeyEntity ) {
        self.mnemonic   = entity.mnemonic
        self.username   = entity.username
        self.mail       = entity.mail ?? ""
        
        if let data = AppKeychain.shared.getPassword(key: entity.mnemonic) {
            self.note = data.comment ?? ""
            self.password = data.password
        }
        else {
            self.note = ""
            self.password = ""

        }

        self.entity = entity

    }

    private func copyTo( entity: KeyEntity ) -> KeyEntity {
        entity.mnemonic = self.mnemonic
        entity.username = self.username
        entity.mail = self.mail
        entity.note = self.note
        
        return entity
    }

    func save( context:NSManagedObjectContext ) throws {
        
        if let entity = self.entity {
            let _ = self.copyTo(entity: entity )
        }
        else {
            let newEntity = KeyEntity( context: context );
            context.insert( self.copyTo(entity: newEntity) )
        }

        AppKeychain.shared.setPassword(     key: self.mnemonic,
                                       password: self.password,
                                        comment: self.note)
        
        try context.save()

    }
    
}


extension SceneDelegate {
    
    var  managedObjectContext:NSManagedObjectContext {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("Unable to read managed object context.")
        }
        return context
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



