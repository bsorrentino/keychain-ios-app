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
    var preferred: Bool?
    @Attribute(.ephemeral) var sectionId: String?
    var url: String?
    public var username: String = ""
    

    public init( mnemonic: String = "",
          groupPrefix: String? = nil,
          group: Bool = false,
          username: String = "",
          mail: String? = nil,
          note: String? = nil,  
          sectionId: String? = nil,
          url: String? = nil,
          expire: Date? = nil,
          preferred: Bool? = false )
          
    {
        self.mnemonic = mnemonic
        self.groupPrefix = groupPrefix
        self.group = group
        self.username = username
        self.mail = mail
        self.note = note
        self.sectionId = sectionId
        self.url = url
        self.expire = expire
        self.preferred = preferred
    }
    


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

        return FetchDescriptor<KeyInfo>( sortBy: [ sort ] )
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
    
    public static func fetchSingleIfPresent(mnemonic: String, inContext context:ModelContext ) throws -> KeyInfo?
    {
        
        let predicate = #Predicate<KeyInfo> {
            $0.mnemonic == mnemonic
        }
        // Check Duplicate
        return try SharedModule.fetchSingleIfPresent(context: context, predicate: predicate, key: mnemonic)
    }
    
    public static func createGroup( groupPrefix:String, inContext context: ModelContext) -> KeyInfo {
        KeyInfo(
            mnemonic: groupPrefix,
            groupPrefix: groupPrefix, 
            group: false,
            username: groupPrefix
        )
    }

    public static func ungroup( _ entity: KeyInfo, inContext context: ModelContext  ) -> Bool {
        
        do {
            entity.groupPrefix = nil
            entity.group = false
            
            try context.save()

            return true
        }
        catch {
            logger.warning( "error ungrouping key \(error.localizedDescription)" )
            return false
        }
    }
    
    private static func deleteSecret( fromEntity entity: KeyInfo) {
        do {
            
            if(  SharedModule.sharedSecrets.containsSecret(withKey: entity.mnemonic ) ) {
                try SharedModule.sharedSecrets.removeSecret(key: entity.mnemonic )
                logger.info( "shared secret \(entity.mnemonic) removed!")
            }
            else if( SharedModule.appSecrets.containsSecret(withKey: entity.mnemonic ) ){
                try SharedModule.appSecrets.removeSecret(key: entity.mnemonic )
                logger.info( "local secret \(entity.mnemonic) removed!")
            }

        }
        catch {
            logger.warning( "error removing password from entity \(entity.mnemonic)\n\(error.localizedDescription)" )
            
        }
       
    }
    
    public static func delete(  _ entity: KeyInfo, inContext context: ModelContext )   {
        
        context.delete(entity)
        
        logger.trace( "object deleted  \(entity.mnemonic)" )
    
        deleteSecret(fromEntity: entity )
        
        do {
            try context.save()
        }
        catch {
            logger.warning( "error removing entity \(entity.mnemonic)\n\(error.localizedDescription)" )
        }
    }
    
    public static func deleteAll( _ context:ModelContext ) throws {

        try context.delete(model: KeyInfo.self )
        
//        print( context.deletedModelsArray.count )
//        context.deletedModelsArray.forEach {
//            if let elem = $0 as? KeyInfo {
//                let _ = deleteSecret( fromEntity: elem )
//            }
//        }

        try context.save()
    }
    

}
