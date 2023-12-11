//
//  GroupKeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by softphone on 29/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared

struct GroupKeyItemList_IOS15: View {
    
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

struct GroupKeyItemList_IOS15_Previews: PreviewProvider {
    
    static func prepareItem() -> KeyInfo {
        let groupItem = KeyInfo()
        groupItem.groupPrefix = "AG0"
        return groupItem

    }
    
    static var previews: some View {
    
        GroupKeyItemList_IOS15( groupEntity: prepareItem() )
            .modelContainer( UIApplication.shared.modelContainer )

    }
}
