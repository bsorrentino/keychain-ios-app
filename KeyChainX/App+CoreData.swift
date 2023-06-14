//
//  App+CoreData.swift
//  KeyChainX
//
//  Created by softphone on 24/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import Combine
import KeychainAccess
import FieldValidatorLibrary
import Shared

extension UIApplication {
    
    var  managedObjectContext:NSManagedObjectContext {
        guard let context = (delegate as? AppDelegate)?.persistentContainer.viewContext else {
            fatalError("Unable to read managed object context.")
        }
        return context
    }

}

extension AppDelegate {
    
    func createSimpleData( container: NSPersistentContainer ) {
        [
            "A0",
            "B0",
            "C0",
            "B1",
            "B2",
        ].forEach {
            let record = KeyEntity(context: container.viewContext)
            record.username = "bartolomeo.sorrentino@soulsoftware.it"
            record.mnemonic = $0
        
            container.viewContext.insert( record )
        }
        
        
        Dictionary( grouping: [
            "AG0-A0",
            "AG0-B0",
            "AG0-C0",
            "AG0-B1",
            "AG0-B2",
            "BG0-A0",
            "BG0-B0",
            "BG0-C0",
            "BG0-B1",
            "BG0-B2",
        ], by: { String($0[..<$0.index( $0.startIndex, offsetBy: 3 )]) })
        .forEach { keyValue in
            let record = KeyEntity(context: container.viewContext)
            record.mnemonic = keyValue.key
            record.groupPrefix = keyValue.key
            record.group = false
            container.viewContext.insert( record )
            
            keyValue.value.forEach { value in
                let record = KeyEntity(context: container.viewContext)
//                if( value.hasSuffix("A0")) {
//                    record.preferred = true
//                }
                record.preferred = true
                record.username = value
                record.mnemonic = value
                record.group = true
                record.groupPrefix = keyValue.key
                
                container.viewContext.insert( record )
            }
            
        }
    }

}
