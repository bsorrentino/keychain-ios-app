//
//  KeyEntity+Decode.swift
//  KeyChainX
//
//  Created by softphone on 16/08/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import CoreData


// MARK: Key Entity Encodable extension
extension KeyEntity : Encodable {

    public  func encode(to encoder: Encoder) throws {
        
        var values = encoder.container(keyedBy: CodingKeys.self)

        try values.encode( self.mnemonic, forKey: .mnemonic)
        try values.encode( self.username, forKey: .username)
        try values.encode( Bool(exactly: self.group), forKey: .group)

        try values.encodeIfPresent(self.groupPrefix, forKey: .groupPrefix)
        try values.encodeIfPresent(self.mail, forKey: .mail)
        try values.encodeIfPresent(self.url, forKey: .url)
        
        try values.encodeIfPresent(self.linkedBy?.mnemonic, forKey: .linkedBy)
        try values.encodeIfPresent(self.linkedTo?.map({ k in k.mnemonic }), forKey: .linkedTo)

    }


}

enum CodingKeys : String, CodingKey {
    case mnemonic = "mnemonic"
    case group = "group"
    case groupPrefix = "groupPrefix"
    case mail = "mail"
    case url = "url"
    case username = "username"
    case linkedTo = "linkedTo"
    case linkedBy = "linkedBy"
    case expire = "expire"

}

struct KeyEntityDecoded : Decodable {
    
    var mnemonic: String
    var username: String
    var group: Bool
    var groupPrefix: String?
    var mail: String?
    var url: String?
    var expire: Date?
    var linkedTo: Set<String>?
    var linkedBy: String?

    init( from decoder: Decoder ) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
                  
        self.mnemonic = try values.decode( String.self, forKey: .mnemonic )
        self.username = try values.decode( String.self, forKey: .username )
        self.group = try values.decode( Bool.self, forKey: .group );
        
        // Optional
        self.groupPrefix  = try values.decodeIfPresent( String.self, forKey: .groupPrefix )
        self.mail         = try values.decodeIfPresent( String.self, forKey: .mail )
        self.url          = try values.decodeIfPresent( String.self, forKey: .url )
        self.linkedTo     = try values.decodeIfPresent( Set<String>.self, forKey: .linkedTo )
        self.linkedBy     = try values.decodeIfPresent( String.self, forKey: .linkedBy )

    }
    
}

