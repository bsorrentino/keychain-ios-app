//
//  App+Keychain.swift
//  KeyChainX
//
//  Created by softphone on 11/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import KeychainAccess
 
class AppKeychain {
    
    // MARK: - Properties

    public static var shared: Keychain = {
        return Keychain()
    }()

    /*
    public static var sharedForUser: Keychain = {
        return Keychain(accessGroup: "userinfo")
    }()
    */
    
}

// MARK: PASSWORD HELPER
func getPasswordFromKeychain( key:String ) -> String {
    do {
        if let password = try AppKeychain.shared.getString( key ) {
            return  password
        }
    }
    catch {
        print( "ERROR: getting element \(key) from keychain.\n\(error)" )
    }
    return ""

}

func setPasswordToKeychain( key:String, password:String )  -> Void {
    do {
        try AppKeychain.shared.set( password, key: key )
    }
    catch {
        print( "ERROR: setting element \(key) to keychain.\n\(error)" )
    }
}

