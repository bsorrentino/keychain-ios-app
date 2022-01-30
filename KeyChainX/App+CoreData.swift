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


extension UIApplication {
    
    var  managedObjectContext:NSManagedObjectContext {
        guard let context = (delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("Unable to read managed object context.")
        }
        return context
    }

}

#if false
class KeyItem : ObservableObject, Decodable {
    
    private var entity:KeyEntity?
    
    @Published var mnemonic: String
    @Published var username: String
    @Published var password: String
    @Published var mail: String
    @Published var note: String
    @Published var url:String
    @Published var expire:Date?
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
        self.url = ""
    }
    
    init( entity: KeyEntity ) {
        self.mnemonic       = entity.mnemonic
        self.username       = entity.username
        self.mail           = entity.mail ?? ""
        self.group          = entity.group.boolValue
        self.groupPrefix    = entity.groupPrefix
        self.expire         = entity.expire
        self.url            = entity.url ?? ""

        if let data = try? UIApplication.shared.getSecrets(groupItem: entity.mnemonic) {
            self.note = data.note ?? ""
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
            
            logger.warning( "invalid item \(try values.decodeIfPresent(String.self, forKey: .mnemonic) ?? "undefined" )" )
            
            for groupItem in values.allKeys {
                logger.trace( "contains \(groupItem.stringValue)")
            }
            
            self.mnemonic = ""
            self.username = ""
            self.password = ""
            self.mail = ""
            self.note = ""
            self.url = ""
            
            return
        }
        
        self.mnemonic = id
        
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
        }
        
        if values.contains(.group) {
            
            let flag = try values.decode(Bool.self, forKey: .group)
            
            self.group = flag
            
        }
        else {
            self.group = false
        }
        
//        if( self.group ) {
//            self.password = ""
//            self.username = id
//        }
//        else {
        
        let passwordValue = try values.decode(String.self, forKey: .password)
        
        self.password = passwordValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.username = try values.decode(String.self, forKey: .username)
        //}
        
        self.mail = try values.decodeIfPresent(String.self, forKey: .mail) ?? ""
        self.note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""

        self.expire = try values.decodeIfPresent(Date.self, forKey: .expire) ?? Date()
        self.url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""

    }

    private func copyTo( entity: KeyEntity ) -> KeyEntity {
        entity.mnemonic     = self.mnemonic
        entity.username     = self.username
        entity.mail         = self.mail
        entity.groupPrefix  = self.groupPrefix
        entity.group = NSNumber( value: group )
        entity.expire       = self.expire
        entity.url          = self.url

        return entity
    }

    func insert( into context:NSManagedObjectContext ) throws {
        
        try UIApplication.shared.setSecrets( groupItem: self.mnemonic, password:self.password, note:self.note)
        
        if let entity = self.entity {
            let _ = self.copyTo(entity: entity )
        }
        else {
            let newEntity = KeyEntity( context: context );
            context.insert( self.copyTo(entity: newEntity) )
        }

    }
    
}
#endif


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
                    
                    let groupItem = try e.toKeyItem()
                    let _ = subscriber.receive(groupItem)
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



