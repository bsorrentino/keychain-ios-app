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
    
    static let KeychainService = "it.softphone.keychain"
    
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
            let keychain = Keychain(service: AccountCredential.KeychainService)
            
            if let token = try? keychain.getString("pwd") { return token }
            return nil
        }
        
        set(value) {
            
            if let v = value  {
                
                let keychain = Keychain(service: AccountCredential.KeychainService)
                
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
    
    var bundleVersion:String? {
        get {
            return  NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String
        }
    }
    
    
    // check if currentVersion is different to bundleVersion
    // return YES if are differents
    func checkAndUpdateCurrentVersion() -> Bool
    {
        guard let v = self.version, let bv = self.bundleVersion else {
            return false
        }
        
        if( v.compare(bv, options:.CaseInsensitiveSearch) != .OrderedSame )
        {
    
            self.version = bv
    
            return true
        }
    
        return false
    }
    
    override init() {
        super.init()
    }
}