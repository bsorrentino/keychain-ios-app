//
//  KeyEntity+Helpers.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 09/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData

let IS_GROUP_CRITERIA = "(groupPrefix != nil AND (group == nil OR group == NO))"


// MARK: Key Entity Helper
extension KeyEntity {
    public static var not_is_a_group_predicate:NSPredicate {
        NSCompoundPredicate(  type: .not, subpredicates: [NSPredicate( format: "groupPrefix != nil AND group = NO")] )
    }
    
    public func isGroup() -> Bool  {
        self.groupPrefix != nil && !self.group.boolValue
    }

    public func isGrouped() -> Bool  {
        group.boolValue
    }

    @nonobjc public class func fetchRequest( withPredicate: NSPredicate? = nil ) -> NSFetchRequest<KeyEntity> {
        let request =  NSFetchRequest<KeyEntity>(entityName: "KeyInfo")
        request.sortDescriptors = [ NSSortDescriptor( key:"mnemonic", ascending: true)]
        
        if let predicate = withPredicate {
            request.predicate = predicate
        }
        
        return request
    }

    @nonobjc public class func fetchCount( forGroupPrefix groupPrefix: String, inContext context: NSManagedObjectContext ) -> Int {
        
        let request = KeyEntity.fetchRequest(withPredicate: NSPredicate(  format: "groupPrefix = %@ AND group = YES", groupPrefix ))

        request.resultType = .countResultType
      
        do {

            return try context.count(for: request)
        }
        catch let error as NSError {
            logger.warning( "error counting groupPrefix: \(groupPrefix) -  \(error)" )
        }
       
        return -1
    }

    public static func createGroup( context: NSManagedObjectContext, groupPrefix:String) -> KeyEntity {
        let group = KeyEntity(context: context)
        group.mnemonic      = groupPrefix
        group.username      = groupPrefix
        group.groupPrefix   = groupPrefix
        group.group         = false

        return group
    }
    
    /**
     
     */
    public static func fetchGroups( ) -> NSFetchRequest<KeyEntity> {

        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
        
        request.predicate = NSPredicate( format: IS_GROUP_CRITERIA )

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.groupPrefix, ascending: true)
        
        request.sortDescriptors = [sortOrder]

        return request
    }
    
    public static func ungroup( _ context: NSManagedObjectContext, entity: KeyEntity ) -> Bool {
        
        do {
            entity.groupPrefix = nil
            entity.group = NSNumber(booleanLiteral: false)
            
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
    
    public static func delete( _ context: NSManagedObjectContext, entity: KeyEntity ) -> Bool {
        
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

}
