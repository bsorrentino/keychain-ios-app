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

    
    convenience init( context: NSManagedObjectContext ) {
        self.init(context: context)
    }
}
