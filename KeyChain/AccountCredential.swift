//
//  AccountCredential.swift
//  KeyChain
//
//  Created by softphone on 01/10/15.
//  Copyright © 2015 SOFTPHONE. All rights reserved.
//

import Foundation

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
    
    var password:String?
    var version:String?
    var encryptionEnabled:Bool?
    
    var bundleVersion:String? {
        get {
            return  NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String
        }
    }
    
    override init() {
        super.init()
    }
}