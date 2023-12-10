//
//  KeyInfo.swift
//  
//
//  Created by bsorrentino on 10/12/23.
//
//

import Foundation
import SwiftData


@Model public class KeyInfo {
    var expire: Date?
    var group: Bool = false
    var groupPrefix: String?
    var mail: String?
    var mnemonic: String = ""
    var note: String?
    var preferred: Bool? = false
    @Attribute(.ephemeral) var sectionId: String?
    var url: String?
    var username: String = ""
    

    public init() { }
    

#warning("Index on KeyInfo:mnemonic is unsupported in SwiftData.")

}
