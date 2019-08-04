//
//  KeyItem.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine

//var ITEM_EMPTY = { UUID().uuidString }()

class KeyItem: /*Codable,*/ ObservableObject {

    enum State {
        case neutral, new, updated
    }

    var willChange = PassthroughSubject<Void, Never>()
    
    var id:String
    var username:String
    var groupPrefix:String?
    var grouped:Bool = false
    var email:String
    var note:String
    var state:State
    
    var password:String {
        get {
            return "the password"
        }
        set(newValue) {
            
        }
    }
    init( state:State ) {
        self.state = state;
        self.id = ""
        self.username = ""
        self.email = ""
        self.note = ""

    }
    
    convenience init( id:String, username:String, email:String = "", note:String = "" ) {
        self.init( state:.neutral )
        self.id = id
        self.username = username
        self.email = email
        self.note = note
    }

    static func newItem() -> KeyItem {
        KeyItem( state:.new )
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
