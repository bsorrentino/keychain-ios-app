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

class FormStatus : ObservableObject {
    @Published var active: Bool = false
    var entity: KeyInfo?
    var clone = false
}

struct KeyItemList: View {
    @Environment(\.modelContext) var context
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
    //    @State private var keyItemListId:Int = 0
    
    @State private var searchText = ""
    @StateObject private var formStatus = FormStatus()
    @State private var isExpanded = true
    
    ///
    /// CellViewLinkGroup
    ///
    /// - Parameter key: Key Entity
    /// - Returns: Group View or Cell View
    @ViewBuilder
    private func CellViewLinkGroup( entity key: KeyInfo ) -> some View {
        if key.isGroup() {
            GroupViewLink( groupEntity: key )
                .listRowInsets( EdgeInsets() )
        }
        else {
            CellViewLink( entity: key,
                          onClone: {
                formStatus.entity = key
                formStatus.clone = true
                formStatus.active = true
            })
            .listRowInsets( EdgeInsets() )
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            DynamicQueryView( withSearchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })
                
               List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        keyItemSection( section: section, 
                                        groupByFirstCharacter: groupByFirstCharacter )
                     }
                }
               .listStyle(.sidebar)
            }
            .toolbar {
                
                ToolbarItem( placement: .navigationBarTrailing ) {
                    Button {
                        formStatus.entity = nil
                        formStatus.active = true
                    } label: {
                        Text("Add")
                    }
                }
            }
            .navigationDestination( isPresented: $formStatus.active ) {
                KeyEntityForm( from: formStatus.entity, clone: formStatus.clone )
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "search keys")
            .navigationBarTitle( Text("Key List"), displayMode: .inline )
            .onChange(of: searchText) { (_ ,_)in
                isExpanded = true
            }
        }
    }
}


extension KeyItemList {
 
    @available( iOS 17, *)
    func Section_iOS17( section: String.Element, groupByFirstCharacter: [String.Element : [KeyInfo]] ) -> some View {

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
    func keyItemSection( section: String.Element, groupByFirstCharacter: [String.Element : [KeyInfo]] ) -> some View {
        
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
    
    KeyItemList()
        .modelContainer( UIApplication.shared.modelContainer)
        .preferredColorScheme(.light)

}

#Preview {
    
    KeyItemList()
        .modelContainer( UIApplication.shared.modelContainer)
        .preferredColorScheme(.dark)

}
