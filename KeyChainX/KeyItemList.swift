//
//  ContentView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemListContentView : View {

    var body: some View {
        NavigationView {
            KeyItemListTopView()
                .navigationBarTitle( Text("Key List"), displayMode: .inline )
        }

    }
}

struct KeyItemListTopView : View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var formActive = false
    
    func showForm() -> some View {
        VStack{
            if formActive {
                KeyEntityForm()
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

struct KeyItemListContentView_Previews : PreviewProvider {
    static var previews: some View {
        KeyItemListContentView()
        
    }
}
#endif
