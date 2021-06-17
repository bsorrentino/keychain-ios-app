//
//  KeyItemList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Cocoa

/**

 */
struct BlueButtonStyle: ButtonStyle {
    var colorScheme:ColorScheme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            //.foregroundColor(configuration.isPressed ? Color.blue : Color.white)
            //.background( configuration.isPressed ? Color.white : Color.blue)
            .background( colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(6.0)
            .padding(2)
    }
}

struct KeyItemListTopbar: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchString = ""
    
    var body: some View {
        HStack {
            Text("Key List")
            SearchBar(text: $searchString, placeholder: "serach mnemonic ....")

        }.padding(5)
    }
}


struct KeyItemListView: View {
    @Environment(\.colorScheme) var colorScheme

    @State var searchString = ""
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Key List")
                SearchBar(text: $searchString, placeholder: "serach mnemonic ....")

            }.padding(5)
            
            KeyItemList( keyFethedResults: FetchRequest( fetchRequest: KeyEntity.fetchRequest( withPredicate: NSPredicate( format: "mnemonic CONTAINS[c] %@", searchString)) ))
        }
        .frame(minWidth: 700, maxHeight: 500)
    }
}

struct KeyItemList: View {
    @Environment(\.colorScheme) var colorScheme
 
    @FetchRequest var keyFethedResults: FetchedResults<KeyEntity>
    
    var body: some View {
        
        List {
          ForEach( keyFethedResults) { key in
            KeyItemRow( item:KeyItem(entity: key) )
          }
        }
    }
}

struct KeyItemList_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return KeyItemListView().environment(\.managedObjectContext, context)
    }
}
