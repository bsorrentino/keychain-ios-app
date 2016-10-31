//
//  keychain2Tests.swift
//  keychain2Tests
//
//  Created by softphone on 27/12/15.
//  Copyright © 2015 SOFTPHONE. All rights reserved.
//

import XCTest

class keychain2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func _testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testVersion() {
        let v = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        
        XCTAssertNotNil(v, "version is null")
        
        let mb = CFBundleGetMainBundle()
        XCTAssertNotNil(mb, "version is null")
        
        let n = CFBundleGetVersionNumber(mb)
        XCTAssertNotEqual(n, 0)
        
        if v == "2.0.1" {
            XCTAssertEqual(n, 33652736)
        }
        else if v == "2.0.2" {
            XCTAssertEqual(n, 33718272)
        }
        
    }
    
}
