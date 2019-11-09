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

}


extension MailEntity {
    
    static func fetchAllMail() -> NSFetchRequest<MailEntity> {
        
        let request:NSFetchRequest<MailEntity> = MailEntity.fetchRequest()
        
        let sortOrder = NSSortDescriptor(keyPath: \MailEntity.value, ascending: true)
        
        request.sortDescriptors = [sortOrder]
        
        return request
        
    }
}


