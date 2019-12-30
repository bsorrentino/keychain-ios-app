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
        self.groupPrefix != nil && !self.group.boolValue
    }

    func isGrouped() -> Bool  {
        group.boolValue
    }

}
