//
//  PreviewContainer.swift
//  KeyChainX
//
//  Created by bsorrentino on 17/12/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import SwiftData
import Shared

@MainActor
let previewContainer = {
    
    do {
        let container = try ModelContainer( for: KeyInfo.self, AttributeInfo.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        SampleData.keys.forEach { key in
            
            container.mainContext.insert( key )
        }
        return container
    }
    catch {
        fatalError("Failed create preview container!")
    }
    
}()


struct SampleData {
    
    static let keys:[KeyInfo] = {
        
        [
            KeyInfo( mnemonic: "A", username: "A" ),
            KeyInfo( mnemonic: "B", username: "B" ),
            KeyInfo.createGroup(groupPrefix: "G1"),
            KeyInfo( mnemonic: "C", groupPrefix: "G1", group:true, username: "C" ),


        ]
        
    }()
    
    
}
