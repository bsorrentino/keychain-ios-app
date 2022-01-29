//
//  KeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 24/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import CoreData



struct KeyItemList2: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
    @State private var keyItemListId:Int = 0
    @State private var searchText = ""
    @State private var formActive = false
    
    @StateObject private var newItem = KeyItem()
    
    private func GroupViewLink( groupIitem item : KeyItem)  -> some View {
        NavigationLink {
            GroupKeyItemList_IOS15( groupItem: item )
        } label: {
            GroupView(groupItem: item)
        }
    }
    private func CellViewLink( item: KeyItem)  -> some View {
        NavigationLink {
            KeyEntityForm( item: item, parentId: $keyItemListId )
        } label: {
            CellView(item: item)
        }
    }

    var body: some View {
        
        NavigationView {

            DynamicFetchRequestView( withSearchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })


                List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        Section( header: Text( String(section) ) ) {
                            
                            ForEach( groupByFirstCharacter[section]!, id: \.self ) { key in
                                let item = KeyItem( entity: key)
                                
                                if item.isGroup {
                                    GroupViewLink( groupIitem: item )
                                }
                                else {
                                    CellViewLink( item: item )
                                }
                            }
                        }
                    }
                }

            }
            .id( keyItemListId ) //
            .searchable(text: $searchText, placement: .automatic, prompt: "search keys")
            .navigationBarTitle( Text("Key List"), displayMode: .inline )
            .navigationBarItems(trailing:
                HStack {
                    NavigationLink( destination: KeyEntityForm(item:newItem, parentId:$keyItemListId),
                                    isActive: $formActive ) {
                        EmptyView()
                    }
                    Button( action: { formActive.toggle() }) {
                        Text("Add")
                        //Image( systemName: "plus" )
                    }
                })

        }
    }
}

extension KeyItemList2 {
    
    struct GroupView : View {
        
        internal var groupItem: KeyItem
        
        var body: some View {
            
            HStack(alignment: .center) {
                Image( systemName: "folder.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding()
                VStack(alignment: .leading) {
                    Text(groupItem.mnemonic).font( .title3)
                    Text(groupItem.groupPrefix ?? "Unknown").font( .subheadline )
                }
            }
    
        }
    }

    struct CellView : View {
        
        internal var item: KeyItem
        
        var body: some View {
            
            HStack(alignment: .center) {
                let subtitle = item.isGrouped ? item.groupPrefix ?? "" : item.username
                Image( systemName: "lock.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding()
                VStack(alignment: .leading) {
                    Text(item.mnemonic).font( .title3)
                    Text(subtitle).font( .subheadline )
                }
            }
        }
    }
}
struct KeyItemList2_Previews: PreviewProvider {
    static var previews: some View {
        KeyItemList2()
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)
    }
}
