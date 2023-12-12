//
//  GroupKeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by softphone on 29/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared

struct GroupKeyItemList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
//    @State private var keyItemListId:Int = 0
    
    internal var groupEntity: KeyInfo
    
    var body: some View {
        
        NavigationView {

            DynamicQueryView( withGroupPrefix: groupEntity.groupPrefix! ) { results in
                
                List( results, id: \.mnemonic ) { key in
                
                    KeyItemList.CellViewLink( entity: key ) 
                }
                // .searchable(text: $searchText, placement: .automatic, prompt: "search keys")

            }
            .navigationBarTitle( Text("Group \(groupEntity.groupPrefix!)"), displayMode: .inline )

        }
    }
}

#Preview {
    GroupKeyItemList( groupEntity: KeyInfo( groupPrefix: "AG0") )
        .modelContainer( UIApplication.shared.modelContainer )

}
