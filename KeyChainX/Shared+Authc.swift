//
//  Authc.swift
//  MacKeyChainX
//
//  Created by Bartolomeo Sorrentino on 12/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import LocalAuthentication
import OSLog

extension LAPolicy : CustomStringConvertible {
   
    public var description: String {
        if( self.rawValue == 1)  {
            return "policy 'deviceOwnerAuthenticationWithBiometrics'"
        }
        if( self.rawValue == 2)  {
            return "policy 'deviceOwnerAuthentication'"
        }
        if( self.rawValue == 3)  {
            return "policy 'deviceOwnerAuthenticationWithWatch'"
        }
        #if os(macOS)
        if( self.rawValue == 4)  {
            return "policy 'deviceOwnerAuthenticationWithBiometricsOrWatch'"
        }
        #endif
        return "policy 'Unknown'"
    }
}


enum AutenticationError: Error {
    case AuthcNotSupported
}

struct Authentication {
    
    private static var _shared = Authentication()
    
    public static var shared:Authentication {
        return _shared
    }
    
    private var context = LAContext()
    
    private init() {}
    
    fileprivate func canEvaluatePolicy(_ policy: LAPolicy) -> Bool {
        var error: NSError?
        
        let support = context.canEvaluatePolicy(policy, error: &error)
        
        if let error = error {
            logger.warning( "error evaulating '\(policy)' - \(error)")
            return false
        }

        return support
    }

    fileprivate func evaluatePolicy(_ policy: LAPolicy, localizedReason reason:String, completionHandler: @escaping (Result<Bool, AutenticationError>) -> Void ) -> Void {
        
        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
            if let error = error {
                return completionHandler( .failure(error as! AutenticationError))
            }
            DispatchQueue.main.async {
                if success {
                    completionHandler( .success(true))
                }
                else {
                    logger.warning( "issue authenticate using authc \(policy)")
                    completionHandler( .success(false))
                }
            }
        }
    }
    
}

extension Authentication {
    

     func tryAuthenticate( reason:String = "We need to unlock application" , completionHandler: @escaping (Result<Bool, AutenticationError>) -> Void ) {
        #if os(macOS)
        if( canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometricsOrWatch )) {
            
            return evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: reason, completionHandler: completionHandler )
        }
        #elseif os(iOS)
        if( canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics )) {
            
            return evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, completionHandler: completionHandler )
        }
        #endif
        if canEvaluatePolicy( .deviceOwnerAuthentication ) {
        
            return evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, completionHandler: completionHandler )
        }
        
        completionHandler( .failure(.AuthcNotSupported) )
        
    }

}
