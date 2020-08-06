//
//  KeyEntity+CoreDataClass.swift
//  KeyChainX
//
//  Created by softphone on 05/08/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//
//

import Foundation
import CoreData

// MARK: Search Criterias

let IS_GROUP_CRITERIA = "(groupPrefix != nil AND (group == nil OR group == NO))"

@objc(KeyEntity)
public class KeyEntity: NSManagedObject {
    
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
