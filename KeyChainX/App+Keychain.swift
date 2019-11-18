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
