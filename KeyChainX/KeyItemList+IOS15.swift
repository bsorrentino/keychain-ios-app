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


private let CELL_IMAGE_PADDING = EdgeInsets( top:20, leading:10, bottom:20, trailing:2)

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
                            
                            ForEach( groupByFirstCharacter[section]!, id: \.self ) { key in
                                
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

//
// MARK: Extension for Cell
//
extension KeyItemList_IOS15 {
    
    private struct CellView : View {
        
        internal var entity: KeyEntity
        
        var body: some View {
            
            HStack(alignment: .center) {
                let subtitle = entity.isGrouped() ? entity.groupPrefix ?? "" : entity.username
                Image( systemName: "lock.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding( CELL_IMAGE_PADDING )
                VStack(alignment: .leading) {
                    Text(entity.mnemonic).font( .title3)
                    Text(subtitle).font( .subheadline ).italic().lineLimit(1)
                }
            }
        }
    }
    
    struct CellViewLink : View {
        
        typealias CellViewHandler = () -> Void
        
        @Environment(\.managedObjectContext) var managedObjectContext
 
        @State private var alertInfo: AlertInfo?
        
        var entity: KeyEntity
        var parentId:Binding<Int>
        var onClone:    CellViewHandler?
        
        /// delete a key
        /// - Parameter entity: entity to remove
        /// - Returns: success status
        private func delete( _ entity: KeyEntity ) -> Bool {
            KeyEntity.delete( self.managedObjectContext, entity: entity)
        }
        
        
        ///  Ungroup Key
        /// - Parameter entity: entity to ungroup
        /// - Returns: success status
        private func ungroup( _ entity: KeyEntity ) -> Bool {
            KeyEntity.ungroup( self.managedObjectContext, entity: entity)
        }
        
        
        var body: some View {
            let item = KeyItem( entity: entity )
            
            NavigationLink {
                KeyEntityForm( item: item, parentId: parentId )
            } label: {
                KeyItemList_IOS15.CellView(entity: entity)
            }
            .alert( item: $alertInfo ) { info in
                Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    primaryButton: .destructive(Text(info.actionText), action: info.action ),
                    secondaryButton: .cancel()
                )
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true ) {
                if onClone != nil {
                    Button {
                        onClone!()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc.fill")
                    }
                    .tint(.green)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
                if entity.isGrouped()  {
                    Button {
                        alertInfo = AlertInfo(
                            id: .ungroup,
                            title: "Are you sure you want ungroup this ?",
                            message: "There is no undo",
                            actionText: "Ungroup",
                            action: { let _ = ungroup(entity) }
                        )

                    } label: {
                        Label("Ungroup", systemImage: "folder.fill.badge.minus")
                    }
                    //.labelStyle(CellViewLink.CustomLabelStyle())
                }
                Button {
                    alertInfo = AlertInfo(
                        id: .delete,
                        title: "Are you sure you want to delete this ?",
                        message: "There is no undo",
                        actionText: "Delete",
                        action: {
                            let _ = delete( entity )
                        }
                    )
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint( .red)
            }
        }
        
        struct CustomLabelStyle: LabelStyle {
            
            func makeBody(configuration: Configuration) -> some View {
                VStack(alignment: .center, spacing: 0) {
                    configuration.icon
                    configuration.title
                }
            }
        }
        
    }
    
}

// MARK: Extension for Group Cell
extension KeyItemList_IOS15 {
    
    
    private struct GroupView : View {
        @Environment(\.managedObjectContext) var managedObjectContext
        
        internal var groupEntity: KeyEntity
        
        private var childrenCount:Int {
            guard let groupPrefix = groupEntity.groupPrefix else { return 0 }
            
            return KeyEntity.fetchCount(forGroupPrefix: groupPrefix, inContext: managedObjectContext)
        }
        
        var body: some View {
            HStack(alignment: .center) {
                Image( systemName: "folder.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding( CELL_IMAGE_PADDING )
                VStack(alignment: .leading) {
                    Text(groupEntity.mnemonic).font( .title3)
                    //Text(groupEntity.groupPrefix ?? "Unknown").font( .subheadline )
                    Text("Children # \(childrenCount)").font( .subheadline )
                }
            }
            
        }
    }
    
    private struct GroupViewLink : View {
        var groupEntity : KeyEntity
        
        var body: some View {
            
            NavigationLink {
                GroupKeyItemList_IOS15( groupEntity: groupEntity )
            } label: {
                KeyItemList_IOS15.GroupView( groupEntity: groupEntity )
            }
        }
    }
    
    
}



struct KeyItemList2_Previews: PreviewProvider {
    static var previews: some View {
        KeyItemList_IOS15()
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)
    }
}
