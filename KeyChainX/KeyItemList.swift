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

    @State private var formActive = false
    
    func showForm() -> some View {
        VStack{
            if formActive {
                KeyEntityForm( key: KeyEntity( context:managedObjectContext ) )
            } else {
                EmptyView()
            }
        }
    }
    var body: some View {
        KeyItemList()
            .navigationBarItems(trailing:
            HStack {
                NavigationLink( destination: showForm(), isActive: $formActive ) { EmptyView() }
                Button( action: {
                    self.formActive = true
                }) {
                    Image( systemName: "plus" )
                }
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
