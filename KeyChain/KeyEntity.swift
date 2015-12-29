//
//  KeyEntity.swift
//  KeyChain
//
//  Created by softphone on 28/12/15.
//  Copyright © 2015 SOFTPHONE. All rights reserved.
//

import Foundation
import CoreData
import KeychainAccess

@objc class StringEncryptionTransformer : NSValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSData.self as AnyClass
    }
    override func transformedValue(value: AnyObject?) -> AnyObject? // by default returns value
    {
        return value
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? // by default raises an exception if +allowsReverseTransformation
    {
        return value
    }
}

@objc class KeyEntity : NSManagedObject {
    
    @NSManaged var mnemonic:String
    @NSManaged var groupPrefix:String?
    @NSManaged var group:NSNumber?;
    @NSManaged var password:NSData;
    @NSManaged var note:String
    
    
    
    static let _MNEMONIC = "mnemonic"
    static let _IS_NEW = "isNew"

    var isNew:Bool {
    
        get {
            let value = self.primitiveValueForKey(KeyEntity._IS_NEW)!.boolValue
            
            return value;
            
        }
    
    }
    
    var sectionId:String? {
    
        get {
            if let k = self.valueForKey(KeyEntity._MNEMONIC) {
            
                return k.substringWithRange(NSMakeRange(0,1))
            }
            
            return nil
        }
    }
    
    var password2:String {
        
        get {
            let keychain = Keychain(service: AccountCredential.sharedCredential.bundleId)
            
            let data =  try! keychain.getData(self.mnemonic)!
            
            return String(data:data, encoding:NSUTF8StringEncoding)!
        }
        set(value) {
            
            let keychain = Keychain(service: AccountCredential.sharedCredential.bundleId)
            try! keychain
                .accessibility(.WhenUnlocked)
                .set(value.dataUsingEncoding(NSUTF8StringEncoding)!, key: self.mnemonic)

        }
    }

    //MARK: Grouping section
    
    func groupByPrefix( prefix:String? ) -> Void {
    
        if let p = prefix  {
            self.groupPrefix = p;
            self.group = NSNumber(bool: true)
        }
    }
    
    func detachFromGroup() -> Void {
        
        self.groupPrefix = nil;
        self.group = NSNumber(bool: false)
    
    }
    
    //MARK: static implementation section
    
    static let _REGEXP = "(\\w+[-@/])(\\w+)"
    
    static func isSectionAware( key:KeyEntity ) -> Bool {
        
        let predicate = NSPredicate(format: "SELF.mnemonic MATCHES %@", _REGEXP)
        
        return predicate.evaluateWithObject(key)
    }
    
    static func getSectionPrefix( key:KeyEntity, checkIfIsSectionAware:Bool ) -> NSRange {
    
        var result = NSMakeRange(NSNotFound, 0)
        
        if( !checkIfIsSectionAware || KeyEntity.isSectionAware(key) ) {
        
            do {
                let pattern = try NSRegularExpression(pattern: _REGEXP, options:.CaseInsensitive)

                let length = key.mnemonic.characters.count
                
                if let match:NSTextCheckingResult =
                            pattern.firstMatchInString( key.mnemonic,
                                                        options:.ReportCompletion,
                                                        range:NSMakeRange(0, length))
                {

                    result = match.rangeAtIndex(1)
                            
                }

                
            }
            catch let error as NSError {
                
                print ("Error: \(error.domain)")
            }
        
        }
    
        return result
    
    }
    
    static func sectionNameFromPrefix( prefix:String?, trim:Bool ) -> String?  {
        
        guard let p = prefix else {
            return nil;
        }
        
        var pp:String = p
        
        if( trim ) {
            
            pp = p.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        if( pp.isEmpty ) {
            return nil;
        }
        
        let index = pp.endIndex.predecessor()
        
        let result = pp.substringToIndex(index)
        
        return result;
    
    }

    static func createSection(  groupKey:String,
                                groupPrefix:String,
                                inContext context:NSManagedObjectContext) -> KeyEntity?
    {
    
        guard let entity = NSEntityDescription.entityForName("KeyInfo", inManagedObjectContext:context) else {
            return nil
        }

        guard let entityName = entity.name else {
            return nil
        }
            
        guard let cloned = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext:context) as? KeyEntity else {
            return nil
        }
        
        cloned.setValue("nil", forKey: "password")
        cloned.setValue("nil", forKey: "username")
    
        cloned.group = NSNumber(bool: false)
        cloned.mnemonic = groupKey;
        cloned.groupPrefix = groupPrefix;

        return cloned
    }
    
    static func copyPasswordToKeychain( context:NSManagedObjectContext ) {
        
        let fetchRequest = NSFetchRequest(entityName: "KeyInfo")
                
        do {

            if let result = try context.executeFetchRequest(fetchRequest) as? [KeyEntity] {
             
                result.forEach({ (kk:KeyEntity) -> () in

                    guard   let data = kk.valueForKey("password") as? NSData,
                            let key = kk.valueForKey("mnemonic") as? String else {
                        return
                    }
                    
                    if let password = NSString(data:data, encoding:NSUTF8StringEncoding) as? String {
                    
                        print("key:\(key) password:\(password)")
                    
                        try! Keychain(service: AccountCredential.sharedCredential.bundleId)
                            .accessibility(.WhenUnlocked)
                            .set(data, key: key)
                    }
                    
                })
            }
        }
        catch let error as NSError {
            print( "error perform fetch \(error.userInfo)")
        }
        
        
        
    }
    
    // MARK: implementation
    
    func isSection() -> Bool {
        return self.groupPrefix != nil && (self.group == nil || self.group?.boolValue == false)
    }
    
    func isGrouped() -> Bool {
        return (self.groupPrefix != nil && self.group != nil && self.group!.boolValue)
    }
    
    func isEqualForImport( object:AnyObject? ) -> Bool {
    
        guard let o = object  else {
            return false
        }
        
        
        var k1:String?
    
        if ( o is KeyEntity ) {
    
            k1 = o.mnemonic;
    
        }
        else if( o is NSDictionary ) {
    
            let d = o as! NSDictionary
            
            k1 = d.valueForKey(KeyEntity._MNEMONIC) as? String
    
        }
        else if( o is String ) {
    
            k1 = o as? String
    
        }
    
        
        return self.mnemonic == k1
        
        
    
    }
    
    
    override func awakeFromFetch() {
    
        self.setPrimitiveValue(NSNumber(bool:false), forKey:KeyEntity._IS_NEW)
    
    }
    
    
    override func didSave() {
        
        self.setPrimitiveValue(NSNumber(bool:false), forKey:KeyEntity._IS_NEW)
    }
    
    //MARK: Serialization
    
    func toDictionary( target:NSMutableDictionary? ) -> NSDictionary? {
    
        guard let t = target else {
            return target;
        }
    
        self.entity.attributesByName.forEach { (key:String, attribute:NSAttributeDescription) -> () in
            
            if key == KeyEntity._IS_NEW {
                
                if let value = self.valueForKey(key) {
                    
                    t.setObject(value, forKey: key)
                }
            }
            
        }
        return t;
    }
    
    func fromDictionary(source:NSDictionary?) {
    
        guard let s = source else {
            return
        }
    
        self.entity.attributesByName.forEach { (key:String, attribute:NSAttributeDescription) -> () in
        
            if key == KeyEntity._IS_NEW {

                if let value = s.valueForKey(key) {
                    
                    self.setValue(value, forKey: key)
                }
            }
        }
    }

}
