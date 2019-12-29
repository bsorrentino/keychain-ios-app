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

let IS_GROUP_CRITERIA = "(groupPrefix != nil AND (group == nil OR group == NO))"
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

//
// @see https://www.avanderlee.com/swift/nsbatchdeleterequest-core-data/
//
func deleteAll( into context:NSManagedObjectContext ) throws {
    
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: KeyEntity.fetchRequest())
    
    batchDeleteRequest.resultType = .resultTypeObjectIDs

    let result = try context.execute(batchDeleteRequest) as! NSBatchDeleteResult
    
    let objectIDs = result.result as! [NSManagedObjectID]
    
    print("#deleted \(objectIDs.count)")
    
    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
    
    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
}


func backupData( to FileName:String, from context:NSManagedObjectContext ) throws {
    
    
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
    @Published var groupPrefix: String? {
        didSet {
            group = groupPrefix != nil
        }
    }
    var group: Bool?

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

    var isGroup:Bool { return entity?.isGroup() ?? false }
    
    var isGrouped:Bool { return entity?.isGrouped() ?? false }
    
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
        self.group = nil
        self.entity = nil
    }
    
    init( entity: KeyEntity ) {
        self.mnemonic       = entity.mnemonic
        self.username       = entity.username
        self.mail           = entity.mail ?? ""
        self.group          = entity.group?.boolValue
        self.groupPrefix    = entity.groupPrefix
        
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

    convenience init( dictionary: NSDictionary ) throws {
        self.init()
        
        var isGroup = false
        
        if let groupPrefix = dictionary["groupPrefix"] as? String {
            self.groupPrefix  = groupPrefix
            
        }

        if let group = dictionary["group"] as? NSNumber {
          self.group = group.boolValue
            
           isGroup = !group.boolValue
        }
        else {
            self.group = false
            print("group \(dictionary["group"] ?? "nil" ) \(dictionary["groupPrefix"]  ?? "nil")" )
        }
        
        
        self.mnemonic = dictionary["mnemonic"] as! String

    
        if( isGroup  ) {
            self.password = ""
            self.username = ""
        }
        else {
            
            guard let password = dictionary["password"] else {
                throw "Passwrd not set!"
            }
            
            if password is Data {
            
                guard let value = String( data: password as! Data, encoding: .utf8) else {
                    throw "Password is invalid!"
                }
                
                self.password = value.trimmingCharacters(in: .whitespacesAndNewlines)
            
            } else if( password is String ) {

                self.password = (password as! String).trimmingCharacters(in: .whitespacesAndNewlines)

            }
            else {
                throw "Password is wrong type!"
            }

            self.username       = dictionary["username"] as! String

        }

        self.mail           = dictionary["mail"] as? String ?? ""
        self.note           = dictionary["note"] as? String ?? ""

    }
    
    func toDictionary() -> Dictionary<String,Any?> {
        
        var group:NSNumber?
        
        if let groupValue = self.group {
            group = NSNumber( value: groupValue )
        }
        
        return [
            "mnemonic": self.mnemonic,
            "username": self.username,
            "password": self.password,
            "mail":self.mail,
            "note":self.note,
            "groupPrefix":self.groupPrefix,
            "group":group
         ]
    }

    private func copyTo( entity: KeyEntity ) -> KeyEntity {
        entity.mnemonic     = self.mnemonic
        entity.username     = self.username
        entity.mail         = self.mail
        entity.note         = self.note
        entity.groupPrefix  = self.groupPrefix
        if let group = self.group {
            entity.group = NSNumber( value: group )
        }
        
        return entity
    }

    func insert( into context:NSManagedObjectContext ) {
        
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



