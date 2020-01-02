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

// MARK: Application Keychain

class AppKeychain {
    
    struct Data {
        var password:String
        var comment:String?
    }
    
    let keychain:Keychain
    
    // MARK: - Properties

    public static var shared: AppKeychain = {
        return AppKeychain()
    }()

    init() {
        self.keychain = Keychain()
    }
 
    func removeAll() throws {
        try keychain.removeAll()
    }
    
    public func setPassword( key:String, password:String, comment:String = "" )  -> Void {
        do {
            try keychain
                .comment(comment)
                .set( password, key: key )
        }
        catch {
            print( "ERROR: setting element \(key) to keychain.\n\(error)" )
        }
    }

    func getPassword( key:String )  -> Data? {
        
        var result:Data ;
        
        do {
            
            if let password = try keychain.getString( key ) {
                
                result = Data(password: password)
                result.comment = keychain[attributes: key]?.comment ?? ""

                return result;
            }
            
        }
        catch {
            print( "ERROR: getting element \(key) from keychain.\n\(error)" )
        }
        return nil
    }

}
