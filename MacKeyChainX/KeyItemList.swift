//
//  KeyItemList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemList: View {

    @FetchRequest( fetchRequest: KeyEntity.fetchRequest() )
    var keyFethedResults: FetchedResults<KeyEntity>
    
    var body: some View {
        List {
          ForEach( keyFethedResults) { key in
            KeyItemRow( key:key )
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
