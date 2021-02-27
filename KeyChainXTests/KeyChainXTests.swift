//
//  KeyChainXTests.swift
//  KeyChainXTests
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import XCTest
import KeychainAccess
@testable import KeychainX



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
        
        
        let urlRegEx = "^(https?://)?((?:www\\.)?(?:[-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(?:/[-\\w@\\+\\.~#\\?&/=%]*)?)$"
        
        let test1 = {
    
            let urlMatches = "https://www.google.com".groups( for: urlRegEx)
            XCTAssertNotNil( urlMatches )
            XCTAssertEqual( 1, urlMatches.count )
            
            if(urlMatches.count > 0 ) {

                urlMatches[0].forEach { token in print( "test1: '\(token)'" )}

                XCTAssertEqual( 3, urlMatches[0].count )
            }
        }
        
        let test2 = {
            
            let urlMatches = "www.google.com".groups( for: urlRegEx )
            XCTAssertNotNil( urlMatches )
            XCTAssertEqual( 1, urlMatches.count )
            
            if(urlMatches.count > 0 ) {

                urlMatches[0].forEach { token in print( "test2: '\(token)'" ) }

                XCTAssertEqual( 3, urlMatches[0].count )
            }
            
        }

        
        let test3 = {
            
            let urlMatches = "//www.google.com".groups( for: urlRegEx)
            XCTAssertNotNil( urlMatches )
            XCTAssertEqual( 0, urlMatches.count )

        }
        
        test1()
        test2()
        test3()
    }
    
    func testRetrieveInternetCredential() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        Keychain.requestSharedWebCredential { (credentials, error) -> () in
            print( credentials )
            print( error ?? "success" )
        }
       let expectation = self.expectation(description: "getInternetPassword")
        
        let keychain = Keychain(server: "https://github.com", protocolType: .https)
               // .authenticationPrompt("Authenticate to login to server")
               // .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
        
        print("\(keychain)")
        
        keychain.getSharedPassword("bsorrentino") { (password, error) in
            print( "password: \(password ?? "unknown")")
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
