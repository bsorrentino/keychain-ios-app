//
//  KeyInfo.swift
//  
//
//  Created by bsorrentino on 10/12/23.
//
//

import Foundation
import SwiftData


@Model public class KeyInfo {
    // Not supported in CloudKit
    // @Attribute(.unique)
    public var mnemonic: String = ""
    var expire: Date?
    var group: Bool = false
    public var groupPrefix: String?
    var mail: String?
    var note: String?
    var preferred: Bool? = false
    @Attribute(.ephemeral) var sectionId: String?
    var url: String?
    var username: String = ""
    

    public init() { }
    


}

// MARK: Key Entity Encodable extension
extension KeyInfo : Encodable {

    public  func encode(to encoder: Encoder) throws {
        
        var values = encoder.container(keyedBy: KeyInfoCodingKeys.self)

        try values.encode( self.mnemonic, forKey: .mnemonic)
        try values.encode( self.username, forKey: .username)
        
        if let data = try SharedModule.appSecrets.getSecret(forKey: self.mnemonic) {
            try values.encode( data.note ?? "", forKey: .note)
            try values.encode( data.password, forKey: .password)
        }
        
        try values.encode( self.group, forKey: .group)

        try values.encodeIfPresent(self.groupPrefix, forKey: .groupPrefix)
        try values.encodeIfPresent(self.mail, forKey: .mail)
        try values.encodeIfPresent(self.url, forKey: .url)
        try values.encodeIfPresent(self.preferred , forKey: .preferred)

        //try values.encode( self.shared.boolValue, forKey: .shared)
    }


}

enum KeyInfoCodingKeys : String, CodingKey {
    case mnemonic
    case group
    case groupPrefix
    case mail
    case url
    case username
    case password
    case linkedTo
    case linkedBy
    case expire
    case note
    case preferred
    //case shared

}


extension KeyInfo {

    public func isGroup() -> Bool  {
        self.groupPrefix != nil && !self.group
    }

    public func isGrouped() -> Bool  {
        group
    }
    
    public static func fetchPreferred( ) -> FetchDescriptor<KeyInfo> {

        let filter = #Predicate<KeyInfo> { elem in
            elem.preferred ?? false
        }
        
        let sort = SortDescriptor(\KeyInfo.mnemonic, order: .forward)
        
        return FetchDescriptor<KeyInfo>( predicate: filter, sortBy: [ sort ]   )
    }

    public static func fetchGroups( ) -> FetchDescriptor<KeyInfo> {
        // "(groupPrefix != nil AND (group == nil OR group == NO))"
        
        let filter = #Predicate<KeyInfo> { elem in
            elem.groupPrefix != nil && !elem.group
        }
        
        let sort = SortDescriptor(\KeyInfo.groupPrefix, order: .forward)
        
        return FetchDescriptor<KeyInfo>( predicate: filter, sortBy: [ sort ]   )
    }
    
    public static func fetchOrdered( ) -> FetchDescriptor<KeyInfo> {
        
        let sort = SortDescriptor(\KeyInfo.mnemonic, order: .forward)

        return FetchDescriptor<KeyInfo>( sortBy: [ sort ]   )
    }

    public static func fetchCount( forGroupPrefix groupPrefix: String, inContext context: ModelContext ) -> Int {
        let filter = #Predicate<KeyInfo> { elem in
            elem.groupPrefix ==  groupPrefix && elem.group
        }
      
        do {

            return try context.fetchCount(FetchDescriptor<KeyInfo>( predicate: filter ))
        }
        catch let error as NSError {
            logger.warning( "error counting groupPrefix: \(groupPrefix) -  \(error)" )
        }
       
        return -1
    }
    
    public static func createGroup( groupPrefix:String, inContext context: ModelContext) -> KeyInfo {
        let group = KeyInfo()
        group.mnemonic      = groupPrefix
        group.username      = groupPrefix
        group.groupPrefix   = groupPrefix
        group.group         = false

        return group
    }

    public static func ungroup( _ context: ModelContext, entity: KeyInfo ) -> Bool {
        
        do {
            entity.groupPrefix = nil
            entity.group = false
            
            if( !isInPreviewMode ) {
                try context.save()
            }
            return true
        }
        catch {
            logger.warning( "error ungrouping  key \(error.localizedDescription)" )
            return false
        }
    }
    
    public static func delete( _ context: ModelContext, entity: KeyInfo ) -> Bool {
        
        do {
            context.delete(entity)
            
            if( !isInPreviewMode ) {
                try context.save()
            }
            
        }
        catch {
            logger.warning( "error deleting key \(error.localizedDescription)" )
            return false
        }
        
        return true
    }
    
    public static func deleteAllWithMerge( context:ModelContext ) throws {

        context.container.deleteAllData()
        
        //try context.delete(model: KeyInfo.self, where: Predicate.true, includeSubclasses: false )

        //try context.save()
    }
    

}
