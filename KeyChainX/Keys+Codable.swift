//
//  File.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 19/08/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation


class KeysProcessingReport : ObservableObject {
    
    @Published var processed:Int = 0
    @Published var errors:Array<Error> = Array()
    @Published var terminated:Bool = false


}

