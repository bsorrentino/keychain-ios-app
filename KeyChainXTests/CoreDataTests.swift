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
    
            let a1 = try self.insert( inContext: context ) {k in
                k.mnemonic = "A1"
            }
            let _ = try self.insert( inContext: context ) {k in
                k.mnemonic = "A2"
            }
            let _ = try self.insert( inContext: context ) {k in
                k.mnemonic = "A1.1"
                k.addToLinkedTo(a1)
            }
            let _ = try self.insert( inContext: context ) {k in
                k.mnemonic = "A3.1"
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

            result.forEach { k in context.delete(k) }
            
            try context.save()
        }
        catch let error as NSError {
            XCTFail("fail fetching KeyEntity. Error: \(error.userInfo)" )
        }

    }

    func testCoreData() {
        
        guard let context = self.container?.viewContext else {
            XCTFail()
            return
        }
        
        do {

            let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()
            let result = try context.fetch( request )

            XCTAssertEqual(result.count, 4, "number of fetched keys are not what expected!")
            
            result.forEach { (k) in
                print( "mnemonic: \(k.mnemonic)")
            }
            
            let mnemomic = "A1.1"
            guard let a11 = result.filter({ k in k.mnemonic == mnemomic}).first else {
                XCTFail( "menemonic \(mnemomic) not found" )
                return;
            }
            
            guard let linked_2_a11 = a11.linkedTo else {
                XCTFail( "linked item  \(mnemomic) is null" )
                return;
            }
            
            XCTAssertEqual(linked_2_a11.count, 1, "tehere are no linked keys to \(mnemomic)")
            
            guard let linked = linked_2_a11.allObjects[0] as? KeyEntity else  {
                XCTFail( "first linked item to \(mnemomic) is not vaild" )
                return;
            }
            
            XCTAssertEqual(linked.mnemonic, "A1", "the linked item to \(mnemomic) is not correct")
            
            print( linked )

        }
        catch let error as NSError {
            XCTFail("fail fetching KeyEntity error \(error.userInfo)" )
        }


    }

}
