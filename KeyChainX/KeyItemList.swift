//
//  ContentView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct ContentView : View {

    var body: some View {
        NavigationView {
            TopView()
                .navigationBarTitle( Text("Key List") )
        }

    }
}

struct TopView : View {
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        KeyItemList()
            .navigationBarItems(trailing:
            HStack {
                NavigationLink( destination: KeyItemForm( item: KeyEntity( context: managedObjectContext) ), label: {
                    Image( systemName: "plus" )
                })
        })
    }
    
    
}


#if DEBUG

import KeychainAccess

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
#endif
