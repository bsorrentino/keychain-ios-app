//
//  File.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 19/08/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import SwiftUI


class KeysProcessingReport : ObservableObject {
    
    @Published var processed:Int = 0
    @Published var errors = Array<Error>()
    @Published var terminated:Bool = false {
        didSet {
            if terminated {
                url = nil
            }
        }
    }
    
    var url:URL? = nil
    
    func reset() {
        processed = 0
        errors.removeAll()
        terminated = false
    }
}

