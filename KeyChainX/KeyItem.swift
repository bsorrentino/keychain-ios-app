//
//  KeyItem.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine

class KeyItem: /*Codable,*/ BindableObject {

    var didChange = PassthroughSubject<Void, Never>()
    
    var id:String
    var username:String
    var groupPrefix:String?
    var grouped:Bool = false
    var email:String
    var note:String
    
    var password:String {
        get {
            return "the password"
        }
        set(newValue) {
            
        }
    }
    init( id:String, username:String ) {
        self.id = id
        self.username = username
        self.email = ""
        self.note = ""
    }

    
}

extension KeyItem : Hashable {
    static func == (lhs: KeyItem, rhs: KeyItem) -> Bool {
        lhs.id == rhs.id
    }
    

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
