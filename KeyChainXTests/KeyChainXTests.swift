//
//  KeyChainXTests.swift
//  KeyChainXTests
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import XCTest
//@testable import KeyChainX
import KeychainAccess
import CoreData

class KeyChainXTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRegExp() {
        
        if let regex = try? NSRegularExpression(pattern: "[-]$", options: .caseInsensitive) {

        
            var myString = "APPLE-"
            var modString = regex.stringByReplacingMatches(in: myString,
                                                            options: [],
                                                            range:NSRange(myString.startIndex..., in: myString),
                                                            withTemplate: "")
            XCTAssertEqual(modString, "APPLE")
            
                
            myString = "-AP-PLE-"
            modString = regex.stringByReplacingMatches(in: myString,
                                                            options: [],
                                                            range:NSRange(myString.startIndex..., in: myString),
                                                            withTemplate: "")
            XCTAssertEqual(modString, "-AP-PLE")

            myString = "APPLE"
            modString = regex.stringByReplacingMatches(in: myString,
                                                            options: [],
                                                            range:NSRange(myString.startIndex..., in: myString),
                                                            withTemplate: "")
            XCTAssertEqual(modString, "APPLE")


        }
        else {
            XCTFail("regexp is invalid!")
        }
        
        
        print( )

    }
    func testURL() {
        
        let url = URL(fileURLWithPath: "file://myfolder/backoup-0000000.plist")
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url.path, "/file:/myfolder/backoup-0000000.plist")
        
        let lpc = url.lastPathComponent
        
        XCTAssertEqual( lpc, "backoup-0000000.plist")
        XCTAssertTrue( lpc.hasSuffix(".plist") )
        
    }
    
    func testRetrieveInternetCredential() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
       let expectation = self.expectation(description: "getInternetPassword")
        
        let keychain = Keychain(server: "https://www.soulsoftware.it", protocolType: .https)
                .authenticationPrompt("Authenticate to login to server")
                .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
        
        print("\(keychain)")
        
        keychain.getSharedPassword("bsorrentino") { (password, error) in
            XCTAssertNil(password)
            XCTAssertNotNil(error)
            if let error = error {
                print( "ERROR \(error)")
            }
            expectation.fulfill()
            
        }

        waitForExpectations(timeout: 1000)
 
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCoreData() {
        
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
                
                //fatalError("Unresolved error \(error), \(error.userInfo)")
                print( "Unresolved error \(error), \(error.userInfo)" )
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        }

    }

}
