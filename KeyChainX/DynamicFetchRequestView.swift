//
//  DynamicFetchedRequestView.swift
//  KeyChainX
//
//  Created by softphone on 29/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import CoreData

// @ref https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-fetchrequest-with-swiftui
struct DynamicFetchRequestView<T: NSManagedObject, Content: View>: View {
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


