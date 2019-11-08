//
//  MailEntity+CoreDataProperties.swift
//  
//
//  Created by Bartolomeo Sorrentino on 08/11/2019.
//
//

import Foundation
import CoreData


extension MailEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MailEntity> {
        return NSFetchRequest<MailEntity>(entityName: "AttributeInfo")
    }

    @NSManaged public var type: NSNumber?
    @NSManaged public var value: String?

}
