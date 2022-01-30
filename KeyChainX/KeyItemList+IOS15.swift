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

    var body: some View {
        
        NavigationView {

            DynamicFetchRequestView( withSearchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })

                List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        Section( header: Text( String(section) ) ) {
                            
                            ForEach( groupByFirstCharacter[section]!, id: \.self ) { key in
                                
                                if key.isGroup() {
                                    GroupViewLink( groupEntity: key )
                                }
                                else {
                                    CellViewLink( entity: key, parentId: $keyItemListId )
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

// MARK: Extension for Cell
extension KeyItemList2 {
    
    private struct CellView : View {
        
        internal var entity: KeyEntity
        
        var body: some View {
            
            HStack(alignment: .center) {
                let subtitle = entity.isGrouped() ? entity.groupPrefix ?? "" : entity.username
                Image( systemName: "lock.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding()
                VStack(alignment: .leading) {
                    Text(entity.mnemonic).font( .title3)
                    Text(subtitle).font( .subheadline )
                }
            }
        }
    }
    
    struct CellViewLink : View {
        @Environment(\.managedObjectContext) var managedObjectContext
        @State private var showingAlert = false
        var entity: KeyEntity
        var parentId:Binding<Int>
        
        var body: some View {
            let item = KeyItem( entity: entity )
            
            NavigationLink {
                KeyEntityForm( item: item, parentId: parentId )
            } label: {
                KeyItemList2.CellView(entity: entity)
            }
            .alert(isPresented:$showingAlert) {
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
            .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
                    Button {
                        showingAlert.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint( .red)
            }
       }
        
        func delete( _ entity: KeyEntity ) -> Bool {

            do {
                managedObjectContext.delete(entity)

                if( !isInPreviewMode ) {
                    try managedObjectContext.save()
                }

            }
            catch {
                logger.warning( "error deleting key \(error.localizedDescription)" )
                return false
            }

            return true
        }

 
    }

}

// MARK: Extension for Group Cell
extension KeyItemList2 {
    
    
    private struct GroupView : View {
        
        internal var groupEntity: KeyEntity
        
        var body: some View {
            
            HStack(alignment: .center) {
                Image( systemName: "folder.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding()
                VStack(alignment: .leading) {
                    Text(groupEntity.mnemonic).font( .title3)
                    Text(groupEntity.groupPrefix ?? "Unknown").font( .subheadline )
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
                KeyItemList2.GroupView( groupEntity: groupEntity )
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
