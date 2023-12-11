//
//  MailEntity+CoreDataProperties.swift
//  
//
//  Created by Bartolomeo Sorrentino on 08/11/2019.
//
//

import Foundation
import CoreData

#if __COREDATA
extension MailEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MailEntity> {
        let request =  NSFetchRequest<MailEntity>(entityName: "AttributeInfo")
        request.sortDescriptors =  [ NSSortDescriptor(key: "value", ascending:true) ]
        return request
    }

    @NSManaged public var type: NSNumber?
    @NSManaged public var value: String?

}
#endif
