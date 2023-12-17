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
extension KeyItemList {
    
    private struct CellView : View {
        
        var entity: KeyInfo
        
        var body: some View {
            HStack(alignment: .center) {
                let subtitle = entity.isGroup() ? entity.groupPrefix ?? "" : entity.username
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
        
        @Environment(\.modelContext) var context
 
        @State private var alertInfo: AlertInfo?
        
        var entity:     KeyInfo
        var onClone:    CellViewHandler?
        
        init( entity:KeyInfo, onClone: CellViewHandler? = nil) {
        
            self.entity = entity
            self.onClone = onClone
            
        }
        
        /// delete a key
        /// - Parameter entity: entity to remove
        /// - Returns: success status
        private func delete( _ entity: KeyInfo ) {
            KeyInfo.delete( entity, inContext: context )
        }
        
        
        ///  Ungroup Key
        /// - Parameter entity: entity to ungroup
        /// - Returns: success status
        private func ungroup( _ entity: KeyInfo ) -> Bool {
            KeyInfo.ungroup( entity, inContext: context )
        }
        
        
        var body: some View {
            
            NavigationLink {
                KeyEntityForm( from: entity, clone: false )
            } label: {
                KeyItemList.CellView( entity: entity )
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
                            delete( entity )
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
extension KeyItemList {
    
    
    struct GroupView : View {
        @Environment(\.modelContext) var context
        
        var groupEntity: KeyInfo
        
        private var childrenCount:Int {
            guard let groupPrefix = groupEntity.groupPrefix else { return 0 }
            
            return KeyInfo.fetchCount(forGroupPrefix: groupPrefix, inContext: context)
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
        var groupEntity : KeyInfo
        
        var body: some View {
            
            NavigationLink( ) {
                GroupKeyItemList( groupEntity: groupEntity )
            } label: {
                KeyItemList.GroupView( groupEntity: groupEntity )
            }
        }
    }
    
    
}

//struct KeyItemList_IOS15_CellView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyItemList_IOS15_CellView()
//    }
//}
