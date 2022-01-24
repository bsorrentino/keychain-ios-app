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
struct FilteredList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>

    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content

    var body: some View {
        List(fetchRequest, id: \.self) { singer in
            self.content(singer)
        }
    }
    
//    init( withRequest request: NSFetchRequest<T> ) {
//
//        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true)
//
//        request.sortDescriptors = [sortOrder]
//
//        let not_grouped = NSCompoundPredicate( notPredicateWithSubpredicate: NSPredicate( format: "group != nil AND group == YES"))
//
//        if let p = predicate { // FILTER ACTIVE
//
//            let group = NSCompoundPredicate( type: .and, subpredicates: [ NSPredicate( format: "groupPrefix != nil "), not_grouped ])
//
//            request.predicate = NSCompoundPredicate( type: .and, subpredicates: [ NSCompoundPredicate( notPredicateWithSubpredicate: group), p] )
//        }
//        else { // FILTER NOT ACTIVE
//            request.predicate = not_grouped
//        }å
//
//        _fetchRequest = request
//    }

    init( withPredicate predicate: NSPredicate, andSortDescriptor sortDescriptors: [NSSortDescriptor] = [],  @ViewBuilder content: @escaping (T) -> Content) {
        
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }
}

// Initilaizer for KeyEntity
extension FilteredList where T : KeyEntity {

    init( searchText: String, @ViewBuilder content: @escaping (T) -> Content) {
        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true)

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
        
        self.init( withPredicate: final_predicate, andSortDescriptor: [sortOrder],  content: content)
    }

}

struct KeyItemList2: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var searchText = ""

    var body: some View {
        
        NavigationView {

            FilteredList( searchText: searchText ) { key in
                Text("\(key.mnemonic)")
            }
            .searchable(text: $searchText)
            .navigationTitle("Searchable Example")
        }
    }
}

struct SwiftUIView2_Previews: PreviewProvider {
    static var previews: some View {
        KeyItemList2()
            //.environment(\.managedObjectContext, UIApplication.shared.managedObjectContext)
    }
}
