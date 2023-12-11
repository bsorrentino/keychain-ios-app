//
//  PreferredView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 13/06/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared
import SwiftData

struct PreferredKeyItemList_IOS15: View {
    
    @Query(KeyInfo.fetchPreferred()) var preferredKeys: [KeyInfo]
    
    var body: some View {
        
        NavigationView {
            
            let groupByFirstCharacter = Dictionary( grouping: preferredKeys, by: { $0.mnemonic.first! })
            
            List {
                ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                    Section( header: Text( String(section) ) ) {
                        
                        ForEach( groupByFirstCharacter[section]!, id: \.mnemonic ) { key in
                            
                            KeyItemList_iOS15.CellViewLink( entity: key )
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
