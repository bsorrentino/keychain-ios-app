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

    var body: some View {
        HStack {
            Text("Key List")
            Button( action: {
            } ) {
                Image(systemName: "plus.circle")
            }
            
            .buttonStyle(BlueButtonStyle(colorScheme:colorScheme))

        }.padding(5)
    }
}

struct KeyItemList: View {

    @FetchRequest( fetchRequest: KeyEntity.fetchRequest())
    var keyFethedResults: FetchedResults<KeyEntity>
    
    var body: some View {
        
        VStack {
            
            KeyItemListTopbar()
            
            List {
              ForEach( keyFethedResults) { key in
                KeyItemRow( key:key )
              }
            }
        }.frame(minWidth: 700, minHeight: 300)
    }
}

struct KeyItemList_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return KeyItemList().environment(\.managedObjectContext, context)
    }
}
