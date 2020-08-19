//
//  KeyEntity+Decode.swift
//  KeyChainX
//
//  Created by softphone on 16/08/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import UIKit
import CoreData


// MARK: Key Entity Encodable extension
extension KeyEntity : Encodable {

    public  func encode(to encoder: Encoder) throws {
        
        var values = encoder.container(keyedBy: CodingKeys.self)

        try values.encode( self.mnemonic, forKey: .mnemonic)
        try values.encode( self.username, forKey: .username)
        
        if let data = try UIApplication.shared.getSecretIfPresent(key: self.mnemonic) {
            try values.encode( data.note ?? "", forKey: .note)
            try values.encode( data.password, forKey: .password)
        }
        
        try values.encode( self.group.boolValue, forKey: .group)

        try values.encodeIfPresent(self.groupPrefix, forKey: .groupPrefix)
        try values.encodeIfPresent(self.mail, forKey: .mail)
        try values.encodeIfPresent(self.url, forKey: .url)
        
    }


}

enum CodingKeys : String, CodingKey {
    case mnemonic
    case group
    case groupPrefix
    case mail
    case url
    case username
    case password
    case expire
    case note

}


