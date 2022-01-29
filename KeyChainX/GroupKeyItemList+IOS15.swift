//
//  GroupKeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by softphone on 29/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct GroupKeyItemList_IOS15: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
    @State private var keyItemListId:Int = 0
    
    internal var groupItem: KeyItem
    
    var body: some View {
        
        NavigationView {

            DynamicFetchRequestView( withGroupPrefix: groupItem.groupPrefix! ) { results in
                
                List( results, id: \.mnemonic ) { key in
                    let item = KeyItem( entity: key)
                
                    NavigationLink {
                        KeyEntityForm( item: item, parentId: $keyItemListId )
                    } label: {
                        KeyItemList2.CellView(item: item)
                    }
                }
                // .searchable(text: $searchText, placement: .automatic, prompt: "search keys")

            }
            .id( keyItemListId ) //
            .navigationBarTitle( Text("Group \(groupItem.groupPrefix!)"), displayMode: .inline )

        }
    }
}

struct GroupKeyItemList_IOS15_Previews: PreviewProvider {
    
    static func prepareItem() -> KeyItem {
        let groupItem = KeyItem()
        groupItem.groupPrefix = "AG0"
        return groupItem

    }
    
    static var previews: some View {
    
        GroupKeyItemList_IOS15( groupItem: prepareItem() )
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)

    }
}
