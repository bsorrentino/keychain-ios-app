//
//  File.swift
//  
//
//  Created by bsorrentino on 10/12/23.
//

import Foundation
import SwiftData

enum SavingError :Error {
    
    case KeyDoesNotExist( id:String )
    case DuplicateKey( id:String )
    case InvalidItem( id:String )
    case BundleIdentifierUndefined
}

public var persistentContainer:ModelContainer = {
    do {

        return try ModelContainer(for: KeyInfo.self, AttributeInfo.self)
        
    }
    catch {
        fatalError( "Error creating ModelContainer! \(error)")
    }

}()

extension SharedModule {
    
    
    public static func fetchSingleIfPresent<T : PersistentModel>(
        context:ModelContext,
        predicate: Predicate<T>,
        key: String ) throws -> T?
    {
        
        let request = FetchDescriptor<T>( predicate: predicate )
        
        let fetchResult = try context.fetch( request )
        
        if( fetchResult.count == 0 ) {
            return nil
        }
        if( fetchResult.count > 1 ) {
            throw SavingError.DuplicateKey(id: key)
            
        }
        return fetchResult.first 
    }
    
    

}
