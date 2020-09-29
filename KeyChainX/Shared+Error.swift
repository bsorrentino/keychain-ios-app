//
//  App+error.swift
//  KeyChainX
//
//  Created by softphone on 24/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation

//
// Make String compliant with Error protocol
// @see https://www.hackingwithswift.com/example-code/language/how-to-throw-errors-using-strings
//
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
