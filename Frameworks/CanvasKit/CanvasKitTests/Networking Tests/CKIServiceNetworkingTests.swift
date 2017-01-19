//
//  CKIServiceNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIServiceNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchService() {
        let client = MockCKIClient()
        
        client.fetchService()
        XCTAssertEqual(client.capturedPath!, "/api/v1/services/kaltura", "CKIService returned API path for testFetchService was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIService API Interaction Method was incorrect")
    }
}
