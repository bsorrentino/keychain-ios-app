//
//  App+Keychain.swift
//  KeyChainX
//
//  Created by softphone on 11/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftUI

// MARK: Custom @Environment Keychain key
// @see https://medium.com/@SergDort/custom-environment-keys-in-swiftui-49f54a13d140

struct UserPreferencesKeychainKey: EnvironmentKey {
    static let defaultValue: Keychain = Keychain(service: "keychainx.userpreferences")
}

extension EnvironmentValues {
    var UserPreferencesKeychain: Keychain {
        get {
            return self[UserPreferencesKeychainKey.self]
        }
        set {
            self[UserPreferencesKeychainKey.self] = newValue
        }
    }
}


// MARK: Application Keychain extensions

let appKeychain = Keychain()

extension Shared  {
    typealias Secret = ( password:String, note:String? )

    static func getSecretIfPresent( forKey key:String ) throws  -> Secret?  {
             
         guard let value = try appKeychain.getString( key ) else {
             return nil
         }
             
         return (password:value, note:appKeychain[attributes: key]?.comment)
             
    }
    
    static func getSecret( forKey key:String ) throws  -> Secret  {
            
        guard let value = try appKeychain.getString( key ) else {
            throw "no password found for key \(key)"
        }
            
        return (password:value, note:appKeychain[attributes: key]?.comment)
            
    }
    
    static func setSecret( forKey key:String, withPassword password:String, note:String? ) throws  {
        
        if let note = note {
            try appKeychain.comment(note).set( password, key: key )
        }
        else  {
            try appKeychain.set( password, key: key )
        }

    }
    
    static func removeSecret( key: String ) throws {
        try appKeychain.remove(key)

    }

}
