//
//  KeyItemList_IOS15+CellView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 14/06/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared

private let CELL_IMAGE_PADDING = EdgeInsets( top:20, leading:10, bottom:20, trailing:2)

//
// MARK: Extension for Cell
//
extension KeyItemList_iOS15 {
    
    private struct CellView : View {
        
        @ObservedObject var item: KeyItem
        
        var body: some View {
            HStack(alignment: .center) {
                let subtitle = item.isGroup ? item.groupPrefix ?? "" : item.username
                Image( systemName: "lock.circle.fill")
                    .resizable()
                    .frame( width: 32, height: 32, alignment: .leading)
                    .padding( CELL_IMAGE_PADDING )
                VStack(alignment: .leading) {
                    Text(item.mnemonic).font( .title3)
                    Text(subtitle).font( .subheadline ).italic().lineLimit(1)
                }
            }
        }
    }
    
    struct CellViewLink : View {
        
        typealias CellViewHandler = () -> Void
        
        @Environment(\.managedObjectContext) var managedObjectContext
 
        @State private var alertInfo: AlertInfo?
        
        var entity:     KeyEntity
        var onClone:    CellViewHandler?
        @StateObject private var item:KeyItem
        
        init( entity:KeyEntity, onClone: CellViewHandler? = nil) {
        
            self.entity = entity
            self.onClone = onClone
            self._item = StateObject( wrappedValue: KeyItem( entity: entity ) )
            
        }
        
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
            
            NavigationLink {
                KeyEntityForm( item: item )
            } label: {
                KeyItemList_iOS15.CellView( item: item)
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
extension KeyItemList_iOS15 {
    
    
    struct GroupView : View {
        @Environment(\.managedObjectContext) var managedObjectContext
        
        var groupEntity: KeyEntity
        
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
    
    struct GroupViewLink : View {
        var groupEntity : KeyEntity
        
        var body: some View {
            
            NavigationLink {
                GroupKeyItemList_IOS15( groupEntity: groupEntity )
            } label: {
                KeyItemList_iOS15.GroupView( groupEntity: groupEntity )
            }
        }
    }
    
    
}

//struct KeyItemList_IOS15_CellView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyItemList_IOS15_CellView()
//    }
//}
