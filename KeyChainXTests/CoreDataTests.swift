//
//  CoreDataTests.swift
//  KeyChainXTests
//
//  Created by softphone on 06/08/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import XCTest
import CoreData
@testable import KeychainX

class CoreDataTests: XCTestCase {
    
    var container:NSPersistentCloudKitContainer? {
        var result:NSPersistentCloudKitContainer? = nil
        
        let container = NSPersistentCloudKitContainer(name: "KeyChain")
        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                let error = "Unresolved error \(error), \(error.userInfo)"
                print( error )
                result = nil
            }
            else {
                container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                result = container
            }
            

        }
        return result
    }
    
    func insert( inContext context:NSManagedObjectContext, fillKey:( KeyEntity ) -> Void  ) throws -> KeyEntity {
        let k = NSEntityDescription.insertNewObject(  forEntityName: "KeyInfo", into: context) as! KeyEntity

        k.group = 0
        k.username = "Me"

        fillKey( k )
        
        context.insert(k)
        
        return k

    }
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        
        guard let context = self.container?.viewContext else {
            XCTFail()
            return
        }


        do {

            let a11 = try self.insert( inContext: context ) {k in
                k.mnemonic = "A1.1"
            }
            let a12 = try self.insert( inContext: context ) {k in
                k.mnemonic = "A1.2"
                
            }
            let _ = try self.insert( inContext: context ) {k in
                k.mnemonic = "A1"
                k.addToLinkedTo(a11)
                k.addToLinkedTo(a12)
            }
            let _ = try self.insert( inContext: context ) {k in
                k.mnemonic = "A2.1"
            }
            let _ = try self.insert( inContext: context ) {k in
                k.mnemonic = "A2"
            }

            try context.save()
        }
        catch let error as NSError {
            XCTFail("fail inserting KeyEntity. Error: \(error.userInfo)" )
        }


    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        guard let context = self.container?.viewContext else {
            XCTFail()
            return
        }

        do {
            let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
            let result = try context.fetch( request )

            result.forEach { k in
                
                switch( k.mnemonic ) {
                case "A1.1", "A1.2", "A2.1", "A1", "A2":
                    context.delete(k)
                default:
                    print( "skip deletion: \(k.mnemonic)" )
                }
                
            }

            try context.save()
        }
        catch let error as NSError {
            XCTFail("fail fetching KeyEntity. Error: \(error.userInfo)" )
        }

    }

    func testCompatibility() {

        guard let container = self.container else {
            XCTFail( "NSPersistentCloudKitContainer is not valid"  )
            return
        }
        
        let persistentStoreDescriptions = container.persistentStoreDescriptions
        
        XCTAssertFalse( persistentStoreDescriptions.isEmpty, "persistentStoreDescriptions is empty" )
        
//        container.persistentStoreDescriptions.forEach { persistentStoreDescription in
//            print( "persistentStoreDescription.url = \(String(describing: persistentStoreDescription.url))")
//        }

        XCTAssertTrue( container.persistentStoreDescriptions.count == 1, "persistentStoreDescriptions is greater than 1" )

        let persistentStoreDescription = container.persistentStoreDescriptions[0]
        
        guard let url = persistentStoreDescription.url else {
            XCTFail( "NSPersistentCloudKitContainer.url is null"  )
            return
        }
        
        print( "URL: \(url)" )
        
        let stores = container.persistentStoreCoordinator.persistentStores
        
        XCTAssertTrue( stores.count == 1, "persistentStores count \(stores.count) doesn't match with 1" )
        
        let store = stores[0]
        
        guard let metadata = stores[0].metadata else {
            XCTFail( "store \(String(describing: store.identifier))  has not valid metadata!"  )
            return
        }
        
        let isCompatible = container.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        
        XCTAssertTrue( isCompatible, "model is not compatible!" )
    }
    
    
    func testCoreData() {
        
        guard let context = self.container?.viewContext else {
            XCTFail()
            return
        }
        
        do {

            let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
            let result = try context.fetch( request )

//            XCTAssertEqual(result.count, 5, "number of fetched keys are not what expected!")
            
//            result.forEach { (k) in
//                print( "mnemonic: \(k.mnemonic)")
//            }
            
            let mnemomic = "A1"
            guard let k = result.filter({ k in k.mnemonic == mnemomic}).first else {
                XCTFail( "menemonic \(mnemomic) not found" )
                return;
            }
            
            guard let linkedTo = k.linkedTo else {
                XCTFail( "linked item  \(mnemomic) is null" )
                return;
            }
            
            XCTAssertEqual(linkedTo.count, 2, "tehere are no linked keys to \(mnemomic)")
            
            linkedTo.forEach { lk in
                print( "linked key of \(mnemomic): \(lk.mnemonic) - \(lk.linkedBy?.mnemonic ?? "nil")")
                
                XCTAssertEqual(lk.linkedBy?.mnemonic, mnemomic)
            }
            
            
        }
        catch let error as NSError {
            XCTFail("fail fetching KeyEntity error \(error.userInfo)" )
        }


    }

}
