//
//  KeyEntity+CoreDataClass.swift
//  
//
//  Created by Bartolomeo Sorrentino on 08/11/2019.
//
//

import Foundation
import CoreData

@objc(KeyEntity)
public class KeyEntity: NSManagedObject {
    /**
     
     */
    static func fetchGroups() -> NSFetchRequest<KeyEntity> {

        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
        
        request.predicate = NSPredicate( format: IS_GROUP_CRITERIA )

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.groupPrefix, ascending: true)
        
        request.sortDescriptors = [sortOrder]

        return request
    }

}


extension MailEntity {
    
    static func fetchAllMail() -> NSFetchRequest<MailEntity> {
        
        let request:NSFetchRequest<MailEntity> = MailEntity.fetchRequest()
        
        let sortOrder = NSSortDescriptor(keyPath: \MailEntity.value, ascending: true)
        
        request.sortDescriptors = [sortOrder]
        
        return request
        
    }
}


