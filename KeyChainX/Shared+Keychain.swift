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

class SecretsManager {
    typealias Secret = ( password:String, note:String? )

    fileprivate var keychain:Keychain
    
    init( delegateTo keychain: Keychain ) {
        self.keychain = keychain
    }

    func containsSecret( withKey key:String ) -> Bool {
        return self.keychain[key] != nil
    }
    
    func getSecret( forKey key:String ) throws -> Secret? {
        
        guard let value = try self.keychain.getString( key ) else {
             return nil
         }
             
         return (password:value, note:self.keychain[attributes: key]?.comment)
             
    }

    func setSecret( forKey key:String, secret:Secret ) throws  {
        
        if let note = secret.note {
            try self.keychain.comment(note).set( secret.password, key: key )
        }
        else  {
            try self.keychain.set( secret.password, key: key )
        }

    }


    func removeSecret( key: String ) throws {
        try self.keychain.remove(key)

    }

}

//
// KEY SWAP SUPPORT
//
extension SecretsManager {
    
    typealias ErrorHandler = (Error) -> Void

    func swapSecret( toManager manager:SecretsManager, forKey key:String, onRemoveError: ErrorHandler? = nil ) throws {
        
        if let prevSecret = try getSecret(forKey: key) {

            try manager.setSecret(forKey: key, secret:prevSecret )

            do {
                try removeSecret(key: key)
            }
            catch {
                print( "WARN: swapSecret( toManager: forKey: )\n\(error)")
                if let handler = onRemoveError  {
                    handler(error)
                }
            }
        }
    }
 
    func setSecret( forKey key:String, secret:Secret, removeFromManager manager:SecretsManager, onRemoveError: ErrorHandler? = nil  ) throws {
        
        try setSecret( forKey: key, secret: secret )
        
        do {
            try manager.removeSecret(key: key)
        }
        catch {
            print( "WARN: setSecret( forKey: secret: removeFromManager: )\n\(error)")
            if let handler = onRemoveError  {
                handler(error)
            }
        }
    }
 
    
}


extension Shared  {

    static let sharedSecrets = SecretsManager( delegateTo:Keychain( service: "org.bsc.KeyChainX.shared", accessGroup: "48J595L9BX.org.bsc.KeyChainX.shared")
                                                .label("keychainx shared (bsorrentino)")
                                                .synchronizable(true)
                                                .accessibility(.whenUnlocked) )
    static let appSecrets = SecretsManager( delegateTo:Keychain() )
    
    static func getWebSharedPassword( forUsername username:String, fromUrl textUrl:String, completionHandler handler: @escaping (Result<String?,Error>) -> Void  ) {
        
        #if os(macOS)
        
        handler( .success(nil) )
        
        #else
        
        if let url = URL(string: textUrl), let scheme = url.scheme, scheme == "https"  {
            
            let keychain = Keychain(server: textUrl, protocolType: .https)
            
            if let password = try? keychain.get(username) {
                print( "password for site \(url.absoluteString) and user \(username) is \(password)")
                
                handler( .success(password) )
                
            }
            else {
                keychain.getSharedPassword(username) { (password, error) -> () in
                    if let error = error {
                        handler( .failure(error) )
                    }
                    else {
                        handler( .success(password) )
                    }
                    if password != nil {
                            // If found password in the Shared Web Credentials,
                            // then log into the server
                            // and save the password to the Keychain

                            
                        } else {
                            // If not found password either in the Keychain also Shared Web Credentials,
                            // prompt for username and password

                            // Log into server

                            // If the login is successful,
                            // save the credentials to both the Keychain and the Shared Web Credentials.
                            print( "password for site \(url.absoluteString) and user \(username) not found!\n\(error ?? "")")
                        }
                    }
            }
            
        }
        #endif
    }
    
}
