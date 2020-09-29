//
//  KeyItemRow.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemRow: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var key:KeyEntity
    
    var body: some View {
        Text( key.mnemonic )
    }
}

struct KeyItemRow_Previews: PreviewProvider {
    
    static var previews: some View {
        KeyItemRow( key:KeyEntity() )
    }
}
