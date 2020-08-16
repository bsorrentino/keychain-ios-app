//
//  KeyEntity+Helpers.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 09/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData

// MARK: Key Entity Helper
extension KeyEntity {

    
    func isGroup() -> Bool  {
        self.groupPrefix != nil && !self.group.boolValue
    }

    func isGrouped() -> Bool  {
        group.boolValue
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
