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

class KeyChainXTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

}
