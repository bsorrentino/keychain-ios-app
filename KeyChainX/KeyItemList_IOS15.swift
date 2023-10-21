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

struct KeyItemList_iOS15: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
    //    @State private var keyItemListId:Int = 0
    
    @State private var searchText = ""
    @State private var formActive = false
    @State private var isExpanded = true
    
    @StateObject private var newItem = KeyItem()
    
    ///
    /// CellViewLinkGroup
    ///
    /// - Parameter key: Key Entity
    /// - Returns: Group View or Cell View
    @ViewBuilder
    private func CellViewLinkGroup( entity key: KeyEntity ) -> some View {
        if key.isGroup() {
            GroupViewLink( groupEntity: key )
                .listRowInsets( EdgeInsets() )
        }
        else {
            CellViewLink( entity: key,
                          onClone: {
                newItem.copy(from: key)
                formActive.toggle()
            })
            .listRowInsets( EdgeInsets() )
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            DynamicFetchRequestView( withSearchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })
                
               List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        keyItemSection( section: section, 
                                        groupByFirstCharacter: groupByFirstCharacter )
                     }
                }
               .listStyle(.sidebar)
            }
            // enable force refresh
            //.id( keyItemListId )
            .toolbar {
                
                ToolbarItem( placement: .navigationBarTrailing ) {
                    Button {
                        formActive.toggle()
                    } label: {
                        Text("Add")
                    }
                }
            }
            .navigationDestination(isPresented: $formActive ) {
                KeyEntityForm(item:newItem)
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "search keys")
            .navigationBarTitle( Text("Key List"), displayMode: .inline )
            .onChange(of: searchText) { _ in
                isExpanded = true
            }
        }
    }
}


extension KeyItemList_iOS15 {
 
    @available( iOS 17, *)
    func Section_iOS17( section: String.Element, groupByFirstCharacter: [String.Element : [FetchedResults<KeyEntity>.Element]] ) -> some View {

        Section( isExpanded: $isExpanded ) 
        {
            ForEach( groupByFirstCharacter[section]!, id: \.mnemonic ) { key in
                
                CellViewLinkGroup( entity: key )
            }
        } header: {
            Text( String(section) )
        }
    }

    @ViewBuilder
    func keyItemSection( section: String.Element, groupByFirstCharacter: [String.Element : [FetchedResults<KeyEntity>.Element]] ) -> some View {
        
        if #available(iOS 17, *) {
            Section_iOS17( section: section, groupByFirstCharacter: groupByFirstCharacter)
        }
        else {
            Section {
                ForEach( groupByFirstCharacter[section]!, id: \.mnemonic ) { key in
                    CellViewLinkGroup( entity: key )
                }
            } header: {
                Text( String(section) )
            }
        }
    }
            
}


#Preview {
    
    ForEach(ColorScheme.allCases, id: \.self) {
        KeyItemList_iOS15()
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)
            .preferredColorScheme($0)
    }

}
