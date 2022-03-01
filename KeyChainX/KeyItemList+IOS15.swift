//
//  KeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 24/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import CoreData


private let CELL_IMAGE_PADDING = EdgeInsets( top:20, leading:10, bottom:20, trailing:2)

struct KeyItemList_IOS15: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Id of KeyItemList view. when change the view is forced to be updated
    // @see https://stackoverflow.com/a/65095862
    // @see https://swiftui-lab.com/swiftui-id/
    @State private var keyItemListId:Int = 0
    @State private var searchText = ""
    @State private var formActive = false
    
    @StateObject private var newItem = KeyItem()
    
    var body: some View {
        
        NavigationView {
            
            DynamicFetchRequestView( withSearchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })
                
                List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        Section( header: Text( String(section) ) ) {
                            
                            ForEach( groupByFirstCharacter[section]!, id: \.self ) { key in
                                
                                Group {
                                    if key.isGroup() {
                                        GroupViewLink( groupEntity: key )
                                    }
                                    else {
                                        CellViewLink( entity: key, parentId: $keyItemListId )
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                            }
                        }
                    }
                }

            }
            .id( keyItemListId )
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
        @Environment(\.managedObjectContext) var managedObjectContext
        @State private var showingAlertForDelete = false
        @State private var showingAlertForUngroup = false
        var entity: KeyEntity
        var parentId:Binding<Int>
        
        var body: some View {
            let item = KeyItem( entity: entity )
            
            NavigationLink {
                KeyEntityForm( item: item, parentId: parentId )
            } label: {
                KeyItemList_IOS15.CellView(entity: entity)
            }
            .alert(isPresented:$showingAlertForDelete) {
                Alert(
                    title: Text("Are you sure you want to delete this?"),
                    message: Text("There is no undo"),
                    primaryButton: .destructive(Text("Delete")) {
                        let _ = delete( entity )
                        parentId.wrappedValue += 1 // force view refresh
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented:$showingAlertForUngroup) {
                Alert(
                    title: Text("Are you sure you want ungroup this?"),
                    message: Text("There is no undo"),
                    primaryButton: .destructive(Text("Ungroup")) {
                        let _ = ungroup( entity )
                        parentId.wrappedValue += 1 // force view refresh
                    },
                    secondaryButton: .cancel()
                )
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true ) {
                Button {
                    
                } label: {
                    Label("Copy", systemImage: "doc.on.doc.fill")
                }
                .tint(.green)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
                if entity.isGrouped() {
                    Button {
                        showingAlertForUngroup.toggle()
                    } label: {
                        Label("Ungroup", systemImage: "folder.fill.badge.minus")
                    }
                    //.labelStyle(CellViewLink.CustomLabelStyle())

                }
                Button {
                    showingAlertForDelete.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint( .red)
            }
        }
        
        func ungroup( _ entity: KeyEntity ) -> Bool {
            KeyEntity.ungroup( self.managedObjectContext, entity: entity)
        }
        
        func delete( _ entity: KeyEntity ) -> Bool {
            KeyEntity.delete( self.managedObjectContext, entity: entity)
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
