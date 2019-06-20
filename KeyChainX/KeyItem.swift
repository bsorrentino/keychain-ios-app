//
//  KeyItem.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine

class KeyItem: /*Hashable, Codable,*/ Identifiable, BindableObject {
    
    var didChange = PassthroughSubject<KeyItem, Never>()
    
    var id:String {
        didSet { didChange.send(self) }
    }
    var username:String {
        didSet { didChange.send(self) }
    }
    var groupPrefix:String? {
        didSet { didChange.send(self) }
    }
    var grouped:Bool = false {
        didSet { didChange.send(self) }
    }
    var note:String? {
        didSet { didChange.send(self) }
    }
    
    init( id:String, username:String ) {
        self.id = id
        self.username = username
    }
}
