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
    @State private var isSearching = false
    @State var keyListId:Int = 0
    @StateObject private var newItem = KeyItem()
    
//    @available(*, deprecated, message: "no longer need")
//    func showForm() -> some View {
//        VStack{
//            if formActive {
//                KeyEntityForm(item:newItem)
//            } else {
//                EmptyView()
//            }
//        }
//    }
    
    var body: some View {
        GeometryReader { geometry in

            KeyItemList( isSearching: self.$isSearching, geometry: geometry.size)
                .id( keyListId )
                .navigationBarItems(trailing:
                    HStack {
                        NavigationLink( destination: KeyEntityForm(item:newItem, parentId:$keyListId),
                                        isActive: $formActive ) {
                            EmptyView()
                        }
                        Button( action: { formActive.toggle() }) {
                            Text("Add")
                            //Image( systemName: "plus" )
                        }.disabled( self.isSearching )
                    })

        }
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
