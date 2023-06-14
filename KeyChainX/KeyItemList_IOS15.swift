//
//  KeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 24/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import CoreData
import Shared


struct AlertInfo: Identifiable {
    typealias AlertAction = () -> Void

    enum AlertType {
        case delete
        case ungroup
    }
    
    let id: AlertType
    let title: String
    let message: String
    let actionText: String
    let action:AlertAction
    
}

struct KeyItemList_IOS15: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
    @State private var keyItemListId:Int = 0
    @State private var searchText = ""
    @State private var formActive = false
    
    @StateObject private var newItem = KeyItem()
    
    var KeyEntityFormNavigationLink: some View {
        NavigationLink( destination: KeyEntityForm(item:newItem, parentId:$keyItemListId),
                        isActive: $formActive ) {
            EmptyView()
        }
    }
    
    ///
    /// CellViewLinkGroup
    ///
    /// - Parameter key: Key Entity
    /// - Returns: Group View or Cell View
    private func CellViewLinkGroup( entity key: KeyEntity ) -> some View {
        Group {
            if key.isGroup() {
                GroupViewLink( groupEntity: key )
            }
            else {
                CellViewLink( entity: key,
                              parentId: $keyItemListId,
                              onClone: {
                                    newItem.copy(from: key)
                                    formActive.toggle()
                                }
                )
            }
        }
        .listRowInsets( EdgeInsets() )
    }
    
    var body: some View {
        
        NavigationView {
            
            DynamicFetchRequestView( withSearchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })
                
                List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        Section( header: Text( String(section) ) ) {
                            
                            ForEach( groupByFirstCharacter[section]!, id: \.mnemonic ) { key in
                                
                                CellViewLinkGroup( entity: key )

                            }
                        }
                    }
                }
                
            }
            // enable force refresh
            //.id( keyItemListId )
            .toolbar {
                ToolbarItem( placement: .navigationBarTrailing ) {
                    Button( action: {
                            formActive.toggle()
                    }) {
                        HStack {
                            KeyEntityFormNavigationLink
                            Text("Add")
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "search keys")
            .navigationBarTitle( Text("Key List"), displayMode: .inline )
            
        }
    }
}





struct KeyItemList2_Previews: PreviewProvider {
    static var previews: some View {
        KeyItemList_IOS15()
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)
    }
}
