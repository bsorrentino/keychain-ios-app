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
class KeyItem : ObservableObject, Decodable {
    
    // MARK: Persistent Fields
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
    @Published var shared:Bool

    
    var group = false
    var linkedTo: Set<String>?
    var linkedBy: String?

    
    // MARK: Accessory Fields
    private weak var entity:KeyEntity?
        
    @Published var username_mail_setter: String = "" {
        didSet {
            username = username_mail_setter
            mail = username_mail_setter
        }
    }

    // MARK: Field Validation
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
        self.shared = false
    }
    
    init( entity: KeyEntity ) {
        
        let key = entity.mnemonic
        let shared = Shared.sharedSecrets.containsSecret(withKey: key)
        
        self.mnemonic       = key
        self.username       = entity.username
        self.mail           = entity.mail ?? ""
        self.group          = entity.group.boolValue
        self.groupPrefix    = entity.groupPrefix
        self.expire         = entity.expire
        self.url            = entity.url ?? ""
        self.shared         = shared
        
        if let data = (shared) ?
            try? Shared.sharedSecrets.getSecret( forKey: key) :
            try? Shared.appSecrets.getSecret( forKey: key)
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
    required init(from decoder: Decoder) throws {
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

        //self.shared =    try values.decodeIfPresent(Bool.self, forKey: .shared) ?? false
        self.shared = Shared.sharedSecrets.containsSecret(withKey: key)
    }

    func reset() {
        self.mnemonic = ""
        self.username = ""
        self.password = ""
        self.mail = ""
        self.note = ""
        self.url = ""
        self.shared = false
    }
    
    
    private func copyTo( entity: KeyEntity ) -> KeyEntity {
        entity.mnemonic     = self.mnemonic
        entity.username     = self.username
        entity.mail         = self.mail
        entity.groupPrefix  = self.groupPrefix
        entity.group        = NSNumber( value: group )
        entity.expire       = self.expire
        entity.url          = self.url

        return entity
    }

    func insert( into context:NSManagedObjectContext ) throws {
        
        let secret = ( password:self.password, note:self.note)
        
        if( self.isNew ) {
            if( self.shared ) {
                try Shared.sharedSecrets.setSecret( forKey: self.mnemonic, secret: secret )
            }
            else {
                try Shared.appSecrets.setSecret( forKey: self.mnemonic, secret: secret )
            }
        }
        else {
            if( self.shared ) {
                try Shared.sharedSecrets.setSecret(forKey: self.mnemonic, secret: secret, removeFromManager: Shared.appSecrets)
            }
            else {
                try Shared.appSecrets.setSecret(forKey: self.mnemonic, secret: secret, removeFromManager: Shared.sharedSecrets)
            }
        }
        
        if let entity = self.entity { // Update
            let _ = self.copyTo(entity: entity )
        }
        else { // Create
            // Check Duplicate
            if let _ = try Shared.fetchSingleIfPresent(context: context, entity: KeyEntity.entity(), predicateFormat: "mnemonic == %@", key: self.mnemonic) {
                
                throw SavingError.DuplicateKey(id: self.mnemonic)
            }
            
            let newEntity = KeyEntity( context: context );

            context.insert( self.copyTo(entity: newEntity) )
        }

    }
    
}

