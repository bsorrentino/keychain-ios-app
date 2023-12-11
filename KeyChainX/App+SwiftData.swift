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
    
    var  modelContainer:ModelContainer {
        guard let container = (delegate as? AppDelegate)?.managerSD.container else {
            fatalError("Unable to read model container.")
        }
        return container
    }

}

