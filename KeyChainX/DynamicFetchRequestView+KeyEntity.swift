//
//  DynamicFetchRequestView+KeyEntity.swift
//  KeyChainX
//
//  Created by softphone on 29/01/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import CoreData

// Initilaizer for KeyEntity
extension DynamicFetchRequestView where T : KeyEntity {
    
    init( withSearchText searchText: String, @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {

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
        
        let request = KeyEntity.fetchRequest( withPredicate: final_predicate )
//        request.propertiesToGroupBy = ["mnemonic"]
//        request.resultType = .dictionaryResultType
        
        self.init( withFetchRequest: request as! NSFetchRequest<T>, content: content)
    }
    
    init( withGroupPrefix groupPrefix: String, @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        
        let request = KeyEntity.fetchRequest(withPredicate: NSPredicate(  format: "groupPrefix = %@ AND group = YES", groupPrefix ))

        self.init( withFetchRequest: request as! NSFetchRequest<T>, content: content)
    }
}
