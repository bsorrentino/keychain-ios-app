//
//  KeyEntity+CoreDataProperties.swift
//  KeyChainX
//
//  Created by softphone on 05/08/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
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
    @NSManaged public var linkedTo: NSSet?

}

// MARK: Generated accessors for linkedTo
extension KeyEntity {

    @objc(addLinkedToObject:)
    @NSManaged public func addToLinkedTo(_ value: KeyEntity)

    @objc(removeLinkedToObject:)
    @NSManaged public func removeFromLinkedTo(_ value: KeyEntity)

    @objc(addLinkedTo:)
    @NSManaged public func addToLinkedTo(_ values: NSSet)

    @objc(removeLinkedTo:)
    @NSManaged public func removeFromLinkedTo(_ values: NSSet)

}
