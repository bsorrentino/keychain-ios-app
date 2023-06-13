//
//  KeyItem.swift
//  KeyChainX
//
//  Created by softphone on 16/08/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import FieldValidatorLibrary
import CoreData


//
// MARK: DISCONNECTED KEYENTITY OBJECT
//
public class KeyItem : ObservableObject, Decodable {
    
    // MARK: Persistent Fields
    @Published public var mnemonic: String
    @Published public var username: String
    @Published public var password: String
    @Published public var mail: String
    @Published public var note: String
    @Published public var url:String
    @Published public var expire:Date?
    @Published public var groupPrefix: String? {
        didSet {
            group = groupPrefix != nil
        }
    }
    @Published public var preferred:Bool
    @Published public var shared:Bool

    
    public var group = false
    var linkedTo: Set<String>?
    var linkedBy: String?

    
    // MARK: Accessory Fields
    private weak var entity:KeyEntity?
        
    public var isNew:Bool { return entity == nil  }

    public var isGroup:Bool { return entity?.isGroup() ?? false }
    
    public var isGrouped:Bool { return entity?.isGrouped() ?? false }
    
    public init() {
        self.mnemonic = ""
        self.username = ""
        self.password = ""
        self.mail = ""
        self.note = ""
        self.url = ""
        self.shared = false
        self.preferred = false
    }
    
    public init( entity: KeyEntity ) {
        
        let key = entity.mnemonic
        let shared = SharedModule.sharedSecrets.containsSecret(withKey: key)
        
        self.mnemonic       = key
        self.username       = entity.username
        self.mail           = entity.mail ?? ""
        self.group          = entity.group.boolValue
        self.groupPrefix    = entity.groupPrefix
        self.expire         = entity.expire
        self.url            = entity.url ?? ""
        self.shared         = shared
        self.preferred      = entity.preferred?.boolValue ?? false
        
        if let data = (shared) ?
            try? SharedModule.sharedSecrets.getSecret( forKey: key) :
            try? SharedModule.appSecrets.getSecret( forKey: key)
        {
            self.note = data.note ?? ""
            self.password = data.password
        }
        else {
            self.note = ""
            self.password = ""
        }
        
        self.entity = entity

    }
    
    // MARK: -
    // MARK: Decodable
    // MARK: -
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let key = try values.decode(String.self, forKey: .mnemonic)
        
        self.mnemonic = key
        self.username = try values.decode(String.self, forKey: .username)
        let passwordValue = try values.decode(String.self, forKey: .password)
        self.password = passwordValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if let prefix = try values.decodeIfPresent(String.self, forKey: .groupPrefix) {
            
            let regex = try NSRegularExpression(pattern: "[-]$", options: .caseInsensitive)
            self.groupPrefix = regex.stringByReplacingMatches(in: prefix,
                                                            options: [],
                                                            range:NSRange(prefix.startIndex..., in: prefix),
                                                            withTemplate: "")
        }
        
        self.group      = try values.decodeIfPresent(Bool.self, forKey: .group) ?? false
                        
        self.mail       = try values.decodeIfPresent(String.self, forKey: .mail) ?? ""
        self.note       = try values.decodeIfPresent(String.self, forKey: .note) ?? ""

        self.expire     = try values.decodeIfPresent(Date.self, forKey: .expire)
        self.url        = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
        
        self.linkedTo   = try values.decodeIfPresent( Set<String>.self, forKey: .linkedTo )
        self.linkedBy   = try values.decodeIfPresent( String.self, forKey: .linkedBy )

        self.preferred = try values.decodeIfPresent( Bool.self, forKey: .preferred ) ?? false
        //self.shared =    try values.decodeIfPresent(Bool.self, forKey: .shared) ?? false
        self.shared = SharedModule.sharedSecrets.containsSecret(withKey: key)
    }

    public func reset() {
        self.mnemonic = ""
        self.username = ""
        self.password = ""
        self.mail = ""
        self.note = ""
        self.url = ""
        self.shared = false
        self.preferred = false
    }
    
    
    private func copyTo( entity: KeyEntity ) -> KeyEntity {
        entity.mnemonic     = self.mnemonic
        entity.username     = self.username
        entity.mail         = self.mail
        entity.groupPrefix  = self.groupPrefix
        entity.group        = NSNumber( value: group )
        entity.expire       = self.expire
        entity.url          = self.url
        entity.preferred    = self.preferred ? 1 : 0
        
        return entity
    }

    public func copy( from entity: KeyEntity ) {
        self.mnemonic       = "\(entity.mnemonic)_1"
        self.username       = entity.username
        self.mail           = entity.mail ?? ""
        self.group          = entity.group.boolValue
        self.groupPrefix    = entity.groupPrefix
        self.expire         = entity.expire
        self.url            = entity.url ?? ""
        self.shared         = false
        self.note           = ""
        self.password       = ""
        self.preferred      = entity.preferred?.boolValue ?? false

    }
    
    @available( macOS, unavailable)
    public func insert( into context:NSManagedObjectContext ) throws {
        
        let secret = SecretsManager.Secret( password:self.password, note:self.note)
        
        if( self.isNew ) {
            if( self.shared ) {
                try SharedModule.sharedSecrets.setSecret( forKey: self.mnemonic, secret: secret )
            }
            else {
                try SharedModule.appSecrets.setSecret( forKey: self.mnemonic, secret: secret )
            }
        }
        else {
            if( self.shared ) {
                try SharedModule.sharedSecrets.setSecret(forKey: self.mnemonic, secret: secret, removeFromManager: SharedModule.appSecrets)
            }
            else {
                try SharedModule.appSecrets.setSecret(forKey: self.mnemonic, secret: secret, removeFromManager: SharedModule.sharedSecrets)
            }
        }
        
        if let entity = self.entity { // Update
            let _ = self.copyTo(entity: entity )
        }
        else { // Create
            // Check Duplicate
            if let _ = try SharedModule.fetchSingleIfPresent(context: context, entity: KeyEntity.entity(), predicateFormat: "mnemonic == %@", key: self.mnemonic) {
                
                throw SavingError.DuplicateKey(id: self.mnemonic)
            }
            
            let newEntity = KeyEntity( context: context );

            context.insert( self.copyTo(entity: newEntity) )
        }

    }
}

