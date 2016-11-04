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
    
    
    static fileprivate var _sharedCredential:AccountCredential?
    
    static var sharedCredential:AccountCredential {
        get{
            if let s = _sharedCredential {
                return s
            }
            _sharedCredential = AccountCredential()
            return _sharedCredential!
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
                
                do {

                    try Keychain(service: bundleId)
                        //.accessibility(.whenUnlocked)
                        .accessibility(.afterFirstUnlock)
                        .set(v, key: "pwd")
                }
                catch  {
                    print( "error set password! \(error)")
                }
            }
            
        }
    }
    
    var version:String? {
        get {
            let prefs = UserDefaults.standard
            return prefs.string(forKey: "ver")
        }
        
        set(value) {
            if let v = value {
                let prefs = UserDefaults.standard
                prefs.set(v, forKey:"ver")
                prefs.synchronize()
            }
        }
        
    }

    var versionNumber:UInt {
        get {
            let prefs = UserDefaults.standard
            return UInt(prefs.integer(forKey: "ver#"))
        }
        
        set(value) {
            let prefs = UserDefaults.standard
            prefs.set( Int(value), forKey:"ver#")
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
            return  Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        }
    }
    
    
    // check if currentVersion is different to bundleVersion
    // return YES if are differents
    func checkAndUpdateCurrentVersion() -> Bool
    {
        guard let bv = self.bundleVersion else {
            return false
        }
        
        if( self.version == nil || bv.compare(self.version!, options:.caseInsensitive) != .orderedSame ){
            self.version = bv
            self.versionNumber = UInt(CFBundleGetVersionNumber(CFBundleGetMainBundle()))
            return true
        }
    
        return false
    }

    // check if currentVersion is different to bundleVersion
    // exec callback if are differents
    func checkCurrentVersion( _ cb:( _ prev:UInt, _ next:UInt ) -> Void ) -> AccountCredential
    {
        let prev = self.versionNumber
        let next = UInt(CFBundleGetVersionNumber(CFBundleGetMainBundle()))
      
        cb( prev, next )
            
        return self
    }
    
    override init() {
        super.init()
    }
}
