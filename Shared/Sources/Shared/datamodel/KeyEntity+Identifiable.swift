//
//  KeyEntity+Identifiable.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 29/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation


extension KeyEntity : Identifiable {
    
    public var id:String { self.mnemonic }

}
