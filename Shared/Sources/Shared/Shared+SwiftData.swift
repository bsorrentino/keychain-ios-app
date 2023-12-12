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

public final class SwiftDataManager {
    public var container: ModelContainer!
    
    public init() {

//        let modelName = "KeyChain"
        
//        guard let modelUrl = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
//            fatalError( "model '\(modelName)' not found!")
//        }
        
        let storeURL = URL.documentsDirectory.appending(path: "KeyChainX.sqlite")
        
        let config = isInPreviewMode ?
            ModelConfiguration(isStoredInMemoryOnly: true) :
//            ModelConfiguration( url: storeURL, cloudKitDatabase: .private("iCloud.KeyChainX") )
//            ModelConfiguration( url: storeURL, cloudKitDatabase: .automatic )
            ModelConfiguration( url: storeURL, cloudKitDatabase: .none )

        do {

            self.container = try ModelContainer(for: KeyInfo.self, AttributeInfo.self, configurations: config)
            
        }
        catch {
            fatalError( "Error creating ModelContainer! \(error)")
        }

    }
}

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
