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

@objc class StringEncryptionTransformer : ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return Data.self as! AnyClass
    }
    override func transformedValue(_ value: Any?) -> Any? // by default returns value
    {
        return value
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? // by default raises an exception if +allowsReverseTransformation
    {
        return value
    }
}

@objc class KeyEntity : NSManagedObject {
    
    @NSManaged var mnemonic:String
    @NSManaged var groupPrefix:String?
    @NSManaged var group:NSNumber?
    @NSManaged var note:String
    
    
    
    static let _MNEMONIC    = "mnemonic"
    static let _PASSWORD    = "password"
    static let _IS_NEW      = "isNew"

    //@TRANSIENT
    var isNew:Bool {
    
        get {
            let value = (self.primitiveValue(forKey: KeyEntity._IS_NEW)! as AnyObject).boolValue
            
            return value!;
            
        }
    
    }
    
    //@TRANSIENT
    var password:String? {
        
        get {
            let keychain = Keychain(service: AccountCredential.sharedCredential.bundleId)
            
            let key = self.mnemonic
            
            if let data =  try! keychain.getString(key) {
                return data
            }
            
            return nil
        }
        set(value) {
            
            if let v = value {
                let keychain = Keychain(service: AccountCredential.sharedCredential.bundleId)
 
                let key = self.mnemonic
                
                try! keychain
                    .accessibility(.whenUnlocked)
                    .set(v, key: key)
            }
        }
    }
    
    var sectionId:String? {
    
        get {
            if let k = self.value(forKey: KeyEntity._MNEMONIC) {
            
                return (k as AnyObject).substring(with: NSMakeRange(0,1))
            }
            
            return nil
        }
    }
    

    //MARK: Grouping section
    
    func groupByPrefix( _ prefix:String? ) -> Void {
    
        if let p = prefix  {
            self.groupPrefix = p;
            self.group = NSNumber(value: true as Bool)
        }
    }
    
    func detachFromGroup() -> Void {
        
        self.groupPrefix = nil;
        self.group = NSNumber(value: false as Bool)
    
    }
    
    //MARK: static implementation section
    
    static let _REGEXP = "(\\w+[-@/])(\\w+)"
    
    static func isSectionAware( _ key:KeyEntity ) -> Bool {
        
        let predicate = NSPredicate(format: "SELF.mnemonic MATCHES %@", _REGEXP)
        
        return predicate.evaluate(with: key)
    }
    
    static func getSectionPrefix( _ key:KeyEntity, checkIfIsSectionAware:Bool ) -> NSRange {
    
        var result = NSMakeRange(NSNotFound, 0)
        
        if( !checkIfIsSectionAware || KeyEntity.isSectionAware(key) ) {
        
            do {
                let pattern = try NSRegularExpression(pattern: _REGEXP, options:.caseInsensitive)

                let length = key.mnemonic.characters.count
                
                if let match:NSTextCheckingResult =
                            pattern.firstMatch( in: key.mnemonic,
                                                        options:.reportCompletion,
                                                        range:NSMakeRange(0, length))
                {

                    result = match.rangeAt(1)
                            
                }

                
            }
            catch let error as NSError {
                
                print ("Error: \(error.domain)")
            }
        
        }
    
        return result
    
    }
    
    static func sectionNameFromPrefix( _ prefix:String?, trim:Bool ) -> String?  {
        
        guard let p = prefix else {
            return nil;
        }
        
        var pp:String = p
        
        if( trim ) {
            
            pp = p.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        if( pp.isEmpty ) {
            return nil;
        }
        
        let index = pp.characters.index(before: pp.endIndex)
        
        let result = pp.substring(to: index)
        
        return result;
    
    }

    static func createSection(  _ groupKey:String,
                                groupPrefix:String,
                                inContext context:NSManagedObjectContext) -> KeyEntity?
    {
    
        guard let entity = NSEntityDescription.entity(forEntityName: "KeyInfo", in:context) else {
            return nil
        }

        guard let entityName = entity.name else {
            return nil
        }
            
        guard let cloned = NSEntityDescription.insertNewObject(forEntityName: entityName, into:context) as? KeyEntity else {
            return nil
        }
        
        cloned.setValue("nil", forKey: "password")
        cloned.setValue("nil", forKey: "username")
    
        cloned.group = NSNumber(value: false as Bool)
        cloned.mnemonic = groupKey;
        cloned.groupPrefix = groupPrefix;

        return cloned
    }
    
    // Copy all passwords to KeyChain and invalidate related password fields
    static func copyPasswordsToKeychain( _ context:NSManagedObjectContext ) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KeyInfo")
                
        do {

            if let result = try context.fetch(fetchRequest) as? [KeyEntity] {
             
                result.forEach({ (kk:KeyEntity) -> () in

                    copyPasswordToKeychain( kk )
                    
                })
            }
        }
        catch let error as NSError {
            print( "error perform fetch \(error.userInfo)")
        }
        
    }
    
    // Copy single password to KeyChain and invalidate related password field
    static func copyPasswordToKeychain( _ kk:KeyEntity ) {
        
        
        guard   let data = kk.value(forKey: "password") as? Data,
            let key = kk.value(forKey: "mnemonic") as? String else {
                return
        }

        do {
            

            if let password = NSString(data:data, encoding:String.Encoding.utf8.rawValue) as? String {
                
                print("key:\(key) password:\(password)")
                
                try Keychain(service: AccountCredential.sharedCredential.bundleId)
                    .accessibility(.whenUnlocked)
                    .set(data, key: key)
                
            }
        
        }
        catch let error as NSError {
            print( "error putting in keychain key \(key) - \(error.userInfo)")
        }
        
        
        
    }
    
    // MARK: implementation
    
    func isSection() -> Bool {
        return self.groupPrefix != nil && (self.group == nil || self.group?.boolValue == false)
    }
    
    func isGrouped() -> Bool {
        return (self.groupPrefix != nil && self.group != nil && self.group!.boolValue)
    }
    
    func isEqualForImport( _ object:AnyObject? ) -> Bool {
    
        guard let o = object  else {
            return false
        }
        
        
        var k1:String?
    
        if ( o is KeyEntity ) {
    
            k1 = o.mnemonic;
    
        }
        else if( o is NSDictionary ) {
    
            let d = o as! NSDictionary
            
            k1 = d.value(forKey: KeyEntity._MNEMONIC) as? String
    
        }
        else if( o is String ) {
    
            k1 = o as? String
    
        }
    
        
        return self.mnemonic == k1
        
        
    
    }
    
    
    override func awakeFromFetch() {
    
        self.setPrimitiveValue(NSNumber(value: false as Bool), forKey:KeyEntity._IS_NEW)
    
    }
    
    
    override func didSave() {
        
        self.setPrimitiveValue(NSNumber(value: false as Bool), forKey:KeyEntity._IS_NEW)
    }
    
    //MARK: Serialization
    
    let sortPredicate = { (A:(key:String, _:NSAttributeDescription), B:(key:String, _:NSAttributeDescription)) -> Bool in
        return A.key < B.key
    }
    
    let filterPredicate = { (E:(key:String, _:NSAttributeDescription)) -> Bool in
        return E.key != KeyEntity._IS_NEW
    }
    
    func toDictionary( _ target:NSMutableDictionary? ) -> NSDictionary? {
    
        guard let t = target else {
            return target;
        }
    
        self.entity.attributesByName
            .filter( filterPredicate )
            .sorted( by: sortPredicate )
            .forEach { (key:String, _:NSAttributeDescription) -> () in
            
                    if let v = self.value(forKey: key) {
                        t.setObject(v, forKey: key as NSCopying)
                    }
                }
            
                
        return t;
    }
    
    func fromDictionary(_ source:NSDictionary?) {
    
        guard let s = source else {
            return
        }
    
        self.entity.attributesByName
            .filter( filterPredicate )
            .sorted( by: sortPredicate )
            .forEach { (key:String, _:NSAttributeDescription) -> () in
        
                if let value = s.value(forKey: key) {
                    self.setValue(value, forKey: key)
                }
            
        }
    }

}
