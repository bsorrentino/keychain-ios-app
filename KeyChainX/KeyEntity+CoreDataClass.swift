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

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey( rawValue: "context")
}


@objc(KeyEntity)
public class KeyEntity: NSManagedObject /*Codable*/ {
    
    convenience init( context: NSManagedObjectContext ) {
        self.init(context: context)
    }
    
//    required public init( from decoder: Decoder ) throws {
//            
//        guard   let contextKey = CodingUserInfoKey.context,
//                let managedObjectContext = decoder.userInfo[contextKey] as? NSManagedObjectContext,
//                let entity = NSEntityDescription.entity(forEntityName: "KeyInfo", in: managedObjectContext)
//            else {
//                throw "error decoding Key"
//            }
//        super.init( entity: entity, insertInto: managedObjectContext)
//
//        try KeyEntity.decode(from: decoder, in: self)
//    }

    
}
