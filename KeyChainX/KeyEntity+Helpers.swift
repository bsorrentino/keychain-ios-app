//
//  KeyEntity+Helpers.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 09/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation

// MARK: Key Entity Helper
extension KeyEntity {

    func isGroup() -> Bool  {
        guard let _ = self.groupPrefix,  self.group?.boolValue ?? false else {
            return false
            
        }
        return true
    }

    func isGrouped() -> Bool  {
        
        guard let group = self.group else { return false }
        
        return group.boolValue
    }

}
