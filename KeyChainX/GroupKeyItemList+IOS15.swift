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
    @State private var keyItemListId:Int = 0
    
    internal var groupEntity: KeyEntity
    
    var body: some View {
        
        NavigationView {

            DynamicFetchRequestView( withGroupPrefix: groupEntity.groupPrefix! ) { results in
                
                List( results, id: \.mnemonic ) { key in
                
                    KeyItemList_IOS15.CellViewLink( entity: key, parentId: $keyItemListId ) 
                }
                // .searchable(text: $searchText, placement: .automatic, prompt: "search keys")

            }
            .id( keyItemListId ) //
            .navigationBarTitle( Text("Group \(groupEntity.groupPrefix!)"), displayMode: .inline )

        }
    }
}

struct GroupKeyItemList_IOS15_Previews: PreviewProvider {
    
    static func prepareItem() -> KeyEntity {
        let groupItem = KeyEntity()
        groupItem.groupPrefix = "AG0"
        return groupItem

    }
    
    static var previews: some View {
    
        GroupKeyItemList_IOS15( groupEntity: prepareItem() )
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)

    }
}
