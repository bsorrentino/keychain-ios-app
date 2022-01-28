//
//  KeyItemList+IOS15.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 24/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import CoreData

// @ref https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-fetchrequest-with-swiftui
struct DynamicFetchedView<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>

    // this is our content closure; we'll call this once for each item in the list
    let content: (FetchedResults<T>) -> Content

    
    var body: some View {
//        List(fetchRequest, id: \.self) { singer in
//            self.content(singer)
//        }
        self.content(fetchRequest)
    }
    
    init( withPredicate predicate: NSPredicate, andSortDescriptor sortDescriptors: [NSSortDescriptor] = [],  @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }
    
    init( withFetchRequest request:NSFetchRequest<T>,  @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        
        _fetchRequest = FetchRequest<T>(fetchRequest: request)
        self.content = content
    }

}

// Initilaizer for KeyEntity
extension DynamicFetchedView where T : KeyEntity {
    
    init( searchText: String, @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        let request = NSFetchRequest<T>(entityName: "KeyInfo")
        
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true) ]
        
        let final_predicate:NSPredicate
        
        let not_grouped_predicate = NSCompoundPredicate( notPredicateWithSubpredicate: NSPredicate( format: "group != nil AND group == YES"))
        
        if !searchText.isEmpty  {
            let group = NSCompoundPredicate( type: .and, subpredicates: [ NSPredicate( format: "groupPrefix != nil "), not_grouped_predicate ])

            let search_criteria = "mnemonic CONTAINS[c] %@ OR groupPrefix CONTAINS[c] %@"
            let search_predicate = NSPredicate(format: search_criteria, searchText, searchText)
            
            final_predicate  = NSCompoundPredicate( type: .and, subpredicates: [ NSCompoundPredicate( notPredicateWithSubpredicate: group), search_predicate] )
        }
        else {
            final_predicate = not_grouped_predicate
        }
        
        request.predicate = final_predicate
//        request.propertiesToGroupBy = ["mnemonic"]
//        request.resultType = .dictionaryResultType
        
        self.init( withFetchRequest: request, content: content)
    }

}

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

            DynamicFetchedView( searchText: searchText ) { results in
                
                let groupByFirstCharacter = Dictionary( grouping: results, by: { $0.mnemonic.first! })


                List {
                    ForEach( groupByFirstCharacter.keys.sorted(), id: \.self ) { section in
                        Section( header: Text( String(section) ) ) {
                            
                            ForEach( groupByFirstCharacter[section]!, id: \.self ) { key in
                                let item = KeyItem( entity: key)
                
                                NavigationLink {
                                    KeyEntityForm( item: item, parentId: $keyItemListId )
                                } label: {
                                    CellView(item)
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
    
    func CellView( _ item: KeyItem ) -> some View {
        
        HStack(alignment: .center) {
            Image( systemName: "lock.circle")
                .padding()
            VStack(alignment: .leading) {
                Text("\(item.mnemonic)").font( .title3)
                Text("\(item.username)").font( .subheadline )
            }
        }

    }

}
struct SwiftUIView2_Previews: PreviewProvider {
    static var previews: some View {
        KeyItemList2()
            .environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)
    }
}
