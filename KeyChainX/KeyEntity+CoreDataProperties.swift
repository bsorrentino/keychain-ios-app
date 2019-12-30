//
//  KeyEntity+CoreDataProperties.swift
//  
//
//  Created by Bartolomeo Sorrentino on 08/11/2019.
//
//

import Foundation
import CoreData


extension KeyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyEntity> {
        return NSFetchRequest<KeyEntity>(entityName: "KeyInfo")
    }

    @NSManaged public var expire: Date?
    @NSManaged public var mail: String?
    @NSManaged public var note: String?
    @NSManaged public var mnemonic: String
    @NSManaged public var sectionId: String?
    @NSManaged public var username: String
    @NSManaged public var group: NSNumber
    @NSManaged public var groupPrefix: String?
    @NSManaged public var url: String?

}
