//
//  AccountCredential.swift
//  KeyChain
//
//  Created by softphone on 01/10/15.
//  Copyright © 2015 SOFTPHONE. All rights reserved.
//

import Foundation
import KeychainAccess

@objc class AccountCredential : NSObject {
    
    
    static private var _sharedCredential:AccountCredential?
    
    static var sharedCredential:AccountCredential {
        get{
            if let s = _sharedCredential {
                return s
            }
            _sharedCredential = AccountCredential()
            return _sharedCredential!
        }
    }
    
    
    var encryptionEnabled:Bool {
        
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            return prefs.boolForKey("encryption")
        }
        
        set(value) {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setBool(value, forKey:"encryption")
            prefs.synchronize()
        }
        
    }
    
    var password:String?  {
        get {
            let keychain = Keychain(service: bundleId)
            
            if let token = try? keychain.getString("pwd") { return token }
            return nil
        }
        
        set(value) {
            
            if let v = value  {
                
                let keychain = Keychain(service: bundleId)
                
                try! keychain
                    .accessibility(.WhenUnlocked)
                    .set(v, key: "pwd")
            }
            
        }
    }
    
    var version:String? {
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            return prefs.stringForKey("ver")
        }
        
        set(value) {
            if let v = value {
                let prefs = NSUserDefaults.standardUserDefaults()
                prefs.setObject(v, forKey:"ver")
                prefs.synchronize()
            }
        }
        
    }

    var versionNumber:UInt {
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            return UInt(prefs.integerForKey("ver#"))
        }
        
        set(value) {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setInteger( Int(value), forKey:"ver#")
            prefs.synchronize()
        }
        
    }
    
    var bundleId:String {
        get {
            return CFBundleGetIdentifier(CFBundleGetMainBundle()) as String
        }
        
    }
    
    var bundleVersion:String? {
        get {
            return  NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String
        }
    }
    
    
    // check if currentVersion is different to bundleVersion
    // return YES if are differents
    func checkAndUpdateCurrentVersion() -> Bool
    {
        guard let bv = self.bundleVersion else {
            return false
        }
        
        if( self.version == nil || bv.compare(self.version!, options:.CaseInsensitiveSearch) != .OrderedSame ){
            self.version = bv
            self.versionNumber = UInt(CFBundleGetVersionNumber(CFBundleGetMainBundle()))
            return true
        }
    
        return false
    }

    // check if currentVersion is different to bundleVersion
    // exec callback if are differents
    func checkCurrentVersion( cb:( prev:UInt, next:UInt ) -> Void ) -> AccountCredential
    {
        let prev = self.versionNumber
        let next = UInt(CFBundleGetVersionNumber(CFBundleGetMainBundle()))
      
        cb( prev:prev, next:next )
            
        return self
    }
    
    override init() {
        super.init()
    }
}