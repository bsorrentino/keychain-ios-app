//
//  KeyEntity+Helpers.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 09/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData

//        @NSManaged public var mnemonic: String
//        @NSManaged public var username: String
//        @NSManaged public var group: NSNumber
//        @NSManaged public var groupPrefix: String?
//        @NSManaged public var mail: String?
//        @NSManaged public var url: String?
//        @NSManaged public var linkedTo: Set<KeyEntity>?
//        @NSManaged public var linkedBy: KeyEntity?

enum CodingKeys : String, CodingKey {
    case mnemonic = "mnemonic"
    case group = "group"
    case groupPrefix = "groupPrefix"
    case mail = "mail"
    case url = "url"
    case username = "username"
    case linkedTo = "linkedTo"
    case linkedBy = "linkedBy"
    case expire = "expire"

}

// MARK: Key Entity Helper
extension KeyEntity : Encodable {

    
    func isGroup() -> Bool  {
        self.groupPrefix != nil && !self.group.boolValue
    }

    func isGrouped() -> Bool  {
        group.boolValue
    }

    class func decode( from decoder: Decoder, in entity: KeyEntity ) throws  -> Void {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
                  
        entity.mnemonic = try values.decode( String.self, forKey: .mnemonic )
        entity.username = try values.decode( String.self, forKey: .username )
        let group = try values.decode( Bool.self, forKey: .group ); entity.group = NSNumber(value: group)
        
        // Optional
        entity.groupPrefix  = try values.decode( String?.self, forKey: .groupPrefix ) ?? nil
        entity.mail         = try values.decode( String?.self, forKey: .mail ) ?? nil
        entity.url          = try values.decode( String?.self, forKey: .url ) ?? nil

    }
    
    public  func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)

        try values.encode( self.mnemonic, forKey: .mnemonic)
        try values.encode( self.username, forKey: .username)
        try values.encode( Bool(exactly: self.group), forKey: .group)

        try values.encodeIfPresent(self.groupPrefix, forKey: .groupPrefix)
        try values.encodeIfPresent(self.mail, forKey: .mail)
        try values.encodeIfPresent(self.url, forKey: .url)
        
        try values.encodeIfPresent(self.linkedBy?.mnemonic, forKey: .linkedBy)
        try values.encodeIfPresent(self.linkedTo?.map({ k in k.mnemonic }), forKey: .linkedTo)

    }
    
    static func createGroup( context: NSManagedObjectContext, groupPrefix:String) -> KeyEntity {
        let group = KeyEntity(context: context)
        group.mnemonic      = groupPrefix
        group.username      = groupPrefix
        group.groupPrefix   = groupPrefix
        group.group         = false

        return group
    }
    /**
     
     */
    static func fetchGroups( ) -> NSFetchRequest<KeyEntity> {

        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
        
        request.predicate = NSPredicate( format: IS_GROUP_CRITERIA )

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.groupPrefix, ascending: true)
        
        request.sortDescriptors = [sortOrder]

        return request
    }

}
