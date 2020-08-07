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
        return NSFetchRequest<KeyEntity>(entityName: "KeyInfo")
    }

    @NSManaged public var expire: Date?
    @NSManaged public var group: NSNumber
    @NSManaged public var groupPrefix: String?
    @NSManaged public var mail: String?
    @NSManaged public var mnemonic: String
    @NSManaged public var sectionId: String?
    @NSManaged public var url: String?
    @NSManaged public var username: String
    @NSManaged public var linkedTo: Set<KeyEntity>?
    @NSManaged public var linkedBy: KeyEntity?

}

// MARK: Generated accessors for linkedTo
extension KeyEntity {

    @objc(addLinkedToObject:)
    @NSManaged public func addToLinkedTo(_ value: KeyEntity)

    @objc(removeLinkedToObject:)
    @NSManaged public func removeFromLinkedTo(_ value: KeyEntity)

    @objc(addLinkedTo:)
    @NSManaged public func addToLinkedTo(_ values: Set<KeyEntity>)

    @objc(removeLinkedTo:)
    @NSManaged public func removeFromLinkedTo(_ values: Set<KeyEntity>)

}
