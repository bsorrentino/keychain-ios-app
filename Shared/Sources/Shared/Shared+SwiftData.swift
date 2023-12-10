//
//  File.swift
//  
//
//  Created by bsorrentino on 10/12/23.
//

import Foundation
import SwiftData

public final class SwiftDataManager {
    public var container: ModelContainer!
    
    public init() {

//        let modelName = "KeyChain"
        
//        guard let modelUrl = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
//            fatalError( "model '\(modelName)' not found!")
//        }
        
        let storeURL = URL.documentsDirectory.appending(path: "KeyChain.sqlite")
        
        let config = isInPreviewMode ?
            ModelConfiguration(isStoredInMemoryOnly: true) :
            ModelConfiguration( url: storeURL )

        do {

            self.container = try ModelContainer(for: AttributeInfo.self, configurations: config)
            
        }
        catch {
            fatalError( "Error creating ModelContainer! \(error)")
        }

    }
}

