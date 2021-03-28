//
//  KeyEntity+CoreDataProperties.swift
//  
//
//  Created by softphone on 07/08/2020.
//
//

import Foundation
import CoreData


extension KeyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyEntity> {
        let request =  NSFetchRequest<KeyEntity>(entityName: "KeyInfo")
        request.sortDescriptors = [ NSSortDescriptor( key:"mnemonic", ascending: true)]
        return request
    }

    @NSManaged public var expire: Date?
    @NSManaged public var group: NSNumber
    @NSManaged public var groupPrefix: String?
    @NSManaged public var mail: String?
    @NSManaged public var mnemonic: String
    @NSManaged public var url: String?
    @NSManaged public var username: String

}

