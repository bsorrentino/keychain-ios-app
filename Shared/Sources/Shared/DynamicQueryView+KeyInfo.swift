//
//  File.swift
//  
//
//  Created by bsorrentino on 11/12/23.
//

import SwiftUI
import SwiftData


extension DynamicQueryView where T : KeyInfo {
    
    public init( withSearchText searchText: String, @ViewBuilder content: @escaping  ([T]) -> Content) {

        let filter: Predicate<T>
        if !searchText.isEmpty  {
            
            filter = #Predicate<T> {
                elem in !elem.group &&
                (elem.mnemonic.localizedStandardContains(searchText) || elem.groupPrefix?.localizedStandardContains(searchText) ?? false ) }
        }
        else {
            
            filter = #Predicate<T> { elem in !elem.group }
            
        }
        self.init( filter: filter,  content: content)
    }
    
    public init( withGroupPrefix groupPrefix: String, @ViewBuilder content: @escaping ( [T] ) -> Content) {
        
        let filter = #Predicate<T> { elem in
            elem.group &&
            elem.groupPrefix == groupPrefix
            
        }
        self.init( filter: filter, content: content)
    }

}
