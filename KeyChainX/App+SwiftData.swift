//
//  App+CoreData.swift
//  KeyChainX
//
//  Created by softphone on 24/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import SwiftData
import Combine
import KeychainAccess
import FieldValidatorLibrary
import Shared

extension UIApplication {
    
    @available(*, deprecated, renamed: "persistentContainer", message: "use persistentContainer")
    var  modelContainer:ModelContainer {
        persistentContainer
    }

}

