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
        HStack {
            Text( key.mnemonic ).frame(minWidth: 150, alignment: .leading)
            Text( key.username).frame(width: 250,alignment: .leading)
            Text( key.mail ?? "").frame(width: 250, alignment: .leading)
            Text( key.url ?? "").frame(width: 250, alignment: .center)
        }.padding(5)
    }
}

struct KeyItemRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let key = { () -> KeyEntity in
            
            let key = KeyEntity( entity:KeyEntity.entity(), insertInto: context )
            
            key.mnemonic = "mnemonic"
            key.username = "bartolomeo.sorrentino@soulsoftware.it"
            key.mail = "bartolomeo.sorrentino@soulsoftware.it"
            key.url = "http://usernamesite.com"

            return key
        }
        return KeyItemRow( key:key() )
    }
}
