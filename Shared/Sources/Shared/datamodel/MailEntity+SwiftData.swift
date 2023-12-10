//
//  File.swift
//  
//
//  Created by bsorrentino on 10/12/23.
//

import Foundation
import SwiftData

@Model public class AttributeInfo {
        
    public var type: Int32? = 0
    public var value: String?
    

    public init( value: String? ) {
        self.value = value
    }
    
}
