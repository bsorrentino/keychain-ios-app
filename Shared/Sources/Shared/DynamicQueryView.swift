//
//  File.swift
//  
//
//  Created by bsorrentino on 11/12/23.
//

import SwiftUI
import SwiftData

public struct DynamicQueryView<T: PersistentModel, Content: View>: View {
    @Query var query: [T]

    // this is our content closure; we'll call this once for each item in the list
    let content: ( [T] ) -> Content

    
    public var body: some View {
        self.content(query)
    }
    
    init( filter: Predicate<T>?, sort: [SortDescriptor<T>] = [],  @ViewBuilder content: @escaping ( [T] ) -> Content) {
        
        _query = Query( filter: filter, sort: sort )
        self.content = content
    }
    
    init( descriptor: FetchDescriptor<T>,  @ViewBuilder content: @escaping ( [T] ) -> Content) {
        
        _query = Query( descriptor )
        self.content = content
    }

}
