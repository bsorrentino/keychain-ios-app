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

 
class KeyItem : ObservableObject, Codable {
    enum CodingKeys: String, CodingKey {
        case mnemonic, username, password, mail, note, groupPrefix, group, expire, url
    }
    
    private var entity:KeyEntity?
    
    @Published var mnemonic: String
    @Published var username: String
    @Published var password: String
    @Published var mail: String
    @Published var note: String
    @Published var expire:Date?
    @Published var url:String?
    @Published var groupPrefix: String? {
        didSet {
            group = groupPrefix != nil
        }
    }
    var group = false

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
    }
    
    init( entity: KeyEntity ) {
        self.mnemonic       = entity.mnemonic
        self.username       = entity.username
        self.mail           = entity.mail ?? ""
        self.group          = entity.group.boolValue
        self.groupPrefix    = entity.groupPrefix
        self.expire         = entity.expire
        self.url            = entity.url

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
    
    
    
    // Decodable
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try values.decodeIfPresent(String.self, forKey: .mnemonic), ( values.contains(.groupPrefix) || values.contains(.password) ) else {
            
            print( "invalid item \(try values.decodeIfPresent(String.self, forKey: .mnemonic) ?? "undefined" )" )
            for key in values.allKeys {
                print( "contains \(key.stringValue)")
            }
            
            self.mnemonic = ""
            self.username = ""
            self.password = ""
            self.mail = ""
            self.note = ""
            
            return
        }
        
        self.mnemonic = id
        
        var isGroup = false

        if values.contains(.groupPrefix) { // Remove suffix '-'
            
            let prefix =  try values.decode(String.self, forKey: .groupPrefix)
            
            if let regex = try? NSRegularExpression(pattern: "[-]$", options: .caseInsensitive) {
                self.groupPrefix = regex.stringByReplacingMatches(in: prefix,
                                                                options: [],
                                                                range:NSRange(prefix.startIndex..., in: prefix),
                                                                withTemplate: "")
            }
            else {
                self.groupPrefix  = prefix
            }
            isGroup = true
        }
        
        if values.contains(.group) {
            
            let flag = try values.decode(Int.self, forKey: .group)
            
            self.group = Bool(truncating: NSNumber(value: flag))
            
            isGroup = !self.group
        }
        else {
            self.group = false
        }
        
        if( isGroup ) {
            self.password = ""
            self.username = id
        }
        else {
            if( !values.contains(.password)) {
                
            }
            if let passwordData = try? values.decode(Data.self, forKey: .password) {
                guard let passwordValue = String( data: passwordData, encoding: .ascii) else {
                    throw "password is not a valid data format!"
                }
                self.password = passwordValue
            }
            else {
                self.password = try values.decode(String.self, forKey: .password)
            }
            self.username = try values.decode(String.self, forKey: .username)
        }
        
        
        self.mail = try values.decodeIfPresent(String.self, forKey: .mail) ?? ""
        self.note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""

        self.expire = try values.decodeIfPresent(Date.self, forKey: .expire) ?? Date()
        self.url = try values.decodeIfPresent(String.self, forKey: .url)

    }

    // Encodable
    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.mnemonic, forKey: .mnemonic)
        try container.encode(self.group, forKey: .group)

        try container.encodeIfPresent(self.username, forKey: .username)
        try container.encodeIfPresent(self.password, forKey: .password)
        try container.encodeIfPresent(self.groupPrefix, forKey: .groupPrefix)
        try container.encodeIfPresent(self.mail, forKey: .mail)
        try container.encodeIfPresent(self.note, forKey: .note)
        try container.encodeIfPresent(self.expire, forKey: .expire)
        try container.encodeIfPresent(self.url, forKey: .url)
    }

    
    private func copyTo( entity: KeyEntity ) -> KeyEntity {
        entity.mnemonic     = self.mnemonic
        entity.username     = self.username
        entity.mail         = self.mail
        entity.note         = self.note
        entity.groupPrefix  = self.groupPrefix
        entity.group = NSNumber( value: group )
        entity.expire       = self.expire
        entity.url          = self.url

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



