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

// MARK: Application Keychain extensions

public class SecretsManager {
    
    public struct Secret : Codable {
        public var password:String
        public var note:String?
        
        public init( password: String, note:String?) {
            self.password = password
            self.note = note
        }
    }
//    public typealias Secret = ( password:String, note:String? )

    fileprivate var keychain:Keychain
    
    public init( delegateTo keychain: Keychain ) {
        self.keychain = keychain
    }

    public func containsSecret( withKey key:String ) -> Bool {
        return self.keychain[key] != nil
    }
    
    public func getSecret( forKey key:String ) throws -> Secret? {
        
        guard let value = try self.keychain.getString( key ) else {
             return nil
         }
             
         return Secret(password:value, note:self.keychain[attributes: key]?.comment)
             
    }

    public func setSecret( forKey key:String, secret:Secret ) throws  {
        
        if let note = secret.note {
            try self.keychain.comment(note).set( secret.password, key: key )
        }
        else  {
            try self.keychain.set( secret.password, key: key )
        }

    }


    public func removeSecret( key: String ) throws {
        try self.keychain.remove(key)

    }

}

//
// KEY SWAP SUPPORT
//
extension SecretsManager {
    
    public typealias ErrorHandler = (Error) -> Void

    public func swapSecret( toManager manager:SecretsManager, forKey key:String, onRemoveError: ErrorHandler? = nil ) throws {
        
        if let prevSecret = try getSecret(forKey: key) {

            try manager.setSecret(forKey: key, secret:prevSecret )

            do {
                try removeSecret(key: key)
            }
            catch {
                logger.warning( "swapSecret( toManager: forKey: )\n\(error.localizedDescription)")
                if let handler = onRemoveError  {
                    handler(error)
                }
            }
        }
    }
 
    public func setSecret( forKey key:String, secret:Secret, removeFromManager manager:SecretsManager, onRemoveError: ErrorHandler? = nil  ) throws {
        
        try setSecret( forKey: key, secret: secret )
        
        do {
            try manager.removeSecret(key: key)
        }
        catch {
            logger.warning( "setSecret( forKey: secret: removeFromManager: )\n\(error.localizedDescription)")
            if let handler = onRemoveError  {
                handler(error)
            }
        }
    }
 
    
}


extension SharedModule  {

    public static let sharedSecrets = SecretsManager( delegateTo:Keychain( service: "org.bsc.KeyChainX.SharedGroup1", accessGroup: "48J595L9BX.keychainXSharedGroup1")
                                                .label("keychainx shared (bsorrentino)")
                                                .synchronizable(true)
                                                .accessibility(.whenUnlocked) )
    public static let appSecrets = SecretsManager( delegateTo:Keychain() )
    
    public static func getWebSharedPassword( forUsername username:String, fromUrl textUrl:String, completionHandler handler: @escaping (Result<String?,Error>) -> Void  ) {
        
        #if os(macOS)
        
        handler( .success(nil) )
        
        #else
        
        if let url = URL(string: textUrl), let scheme = url.scheme, scheme == "https"  {
            
            let keychain = Keychain(server: textUrl, protocolType: .https)
            
            if let password = try? keychain.get(username) {
                logger.trace( "password for site \(url.absoluteString) and user \(username) is \(password)")
                
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
                        logger.debug( "shared password found! \(password!, privacy: .private)")
                            
                    } else {
                        // If not found password either in the Keychain also Shared Web Credentials,
                        // prompt for username and password

                        // Log into server

                        // If the login is successful,
                        // save the credentials to both the Keychain and the Shared Web Credentials.
                        logger.notice( "password for site \(url.absoluteString) and user \(username) not found!")
                    }
                }
            }
            
        }
        #endif
    }
    
}

// MARK: Custom @Environment Keychain key
// @see https://medium.com/@SergDort/custom-environment-keys-in-swiftui-49f54a13d140

public struct UserPreferencesKeychainKey: EnvironmentKey {
    //static let defaultValue: Keychain = Keychain(service: "keychainx.userpreferences")
    public static let defaultValue:SecretsManager = SharedModule.sharedSecrets
}

extension EnvironmentValues {
    public var UserPreferencesKeychain: SecretsManager {
        get {
            return self[UserPreferencesKeychainKey.self]
        }
        set {
            self[UserPreferencesKeychainKey.self] = newValue
        }
    }
}

