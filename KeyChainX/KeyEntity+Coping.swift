//
//  KeyEntity+Coping.swift
//  KeyChainX
//
//  Created by softphone on 01/03/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation

extension KeyEntity : NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        guard let context = self.managedObjectContext else {
            logger.error( "impossible coping KeyEntity '\(self.mnemonic)' because managedcontext is not initialized yet!")
            return Void.self
        }
        
        let result = KeyEntity(context: context)
        
        result.groupPrefix  = self.groupPrefix
        result.group        = self.group
        result.mnemonic     = "\(self.mnemonic)_1"
        result.username     = self.username
        result.url          = self.url
        result.mail         = self.mail
        result.expire       = self.expire

        return result
    }
    
    

}
