//
//  PreferredView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 13/06/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared


struct PreferredKeyItemList_IOS15: View {
    
    @FetchRequest(fetchRequest: KeyEntity.fetchPreferred()) var preferredKeys: FetchedResults<KeyEntity>
    @State private var keyItemListId:Int = 0
    
    var body: some View {
        
        NavigationView {
            
            let groupByFirstCharacter = Dictionary( grouping: preferredKeys, by: { $0.mnemonic.first! })
            
            List {
                ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                    Section( header: Text( String(section) ) ) {
                        
                        ForEach( groupByFirstCharacter[section]!, id: \.mnemonic ) { key in
                            
                            KeyItemList_IOS15.CellViewLink( entity: key,
                                                            parentId: $keyItemListId
                            )
                            .listRowInsets( EdgeInsets() )
                        }
                    }
                }
            }
            .navigationBarTitle( Text("Preferred Keys"), displayMode: .inline )
        }
    }
}

struct PreferredView_Previews: PreviewProvider {
    static var previews: some View {
        PreferredKeyItemList_IOS15()
    }
}
