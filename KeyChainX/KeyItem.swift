//
//  KeyItem.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItem: Hashable, Codable, Identifiable {
    var id:String
    var groupPrefix:String?
    var grouped:Bool = false
    var username:String
    var note:String
    
}
