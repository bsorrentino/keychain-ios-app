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
            Spacer()
            Button( action: {
            } ) {
                Image(systemName: "plus.circle")
            }
            .padding(2)
            .buttonStyle(BlueButtonStyle(colorScheme:colorScheme))

        }
    }
}

struct KeyItemList: View {

    @FetchRequest( fetchRequest: KeyEntity.fetchRequest() )
    var keyFethedResults: FetchedResults<KeyEntity>
    
    var body: some View {
        
        VStack {
            
            KeyItemListTopbar()
            
            List {
              ForEach( keyFethedResults) { key in
                KeyItemRow( key:key )
              }
            }
        }
    }
}

struct KeyItemList_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return KeyItemList().environment(\.managedObjectContext, context)
    }
}
