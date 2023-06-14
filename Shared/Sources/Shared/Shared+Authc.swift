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


public enum AutenticationError: Error {
    case AuthcNotSupported
}

public struct AuthenticationService {
    
    private var context = LAContext()
    
    fileprivate init() {}
    
    fileprivate func canEvaluatePolicy(_ policy: LAPolicy) -> Bool {
        var error: NSError?
        
        let support = context.canEvaluatePolicy(policy, error: &error)
        
        if let error = error {
            logger.warning( "error evaulating '\(policy)' - \(error)")
            return false
        }

        return support
    }

    fileprivate func evaluatePolicy(_ policy: LAPolicy, localizedReason reason:String ) async throws -> Bool {
        
        return try await context.evaluatePolicy(policy, localizedReason: reason)
//        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
//            if let error = error {
//                return completionHandler( .failure(error as! AutenticationError))
//            }
//            DispatchQueue.main.async {
//                if success {
//                    completionHandler( .success(true))
//                }
//                else {
//                    logger.warning( "issue authenticate using authc \(policy)")
//                    completionHandler( .success(false))
//                }
//            }
//        }
    }
    
}

extension AuthenticationService {
    

     public func tryAuthenticate( reason:String = "We need to unlock application" ) async throws -> Bool {
         
        #if os(macOS)
        if( canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometricsOrWatch )) {
            
            return try await evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: reason )
        }
        #elseif os(iOS)
        if( canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics )) {
            
            return try await evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason )
        }
        #endif
        if canEvaluatePolicy( .deviceOwnerAuthentication ) {
        
            return try await evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason )
        }

        throw AutenticationError.AuthcNotSupported
    }
                                                           
}


extension SharedModule  {

    public static let authcService = AuthenticationService()
    
}
