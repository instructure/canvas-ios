//
//  CKIModuleItemNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIModuleItemNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchModuleItemForModule() {
        let moduleDictionary = Helpers.loadJSONFixture("module") as NSDictionary
        let module = CKIModule(fromJSONDictionary: moduleDictionary)
        let client = MockCKIClient()
        
        client.fetchModuleItem("768", forModule: module)
        XCTAssertEqual(client.capturedPath!, "/api/v1/modules/123/items/768", "CKIModuleItem returned API path for testFetchModuleItemForModule was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIModuleItem API Interaction Method was incorrect ")
    }

    func testFetchModuleItemsForModule() {
        let moduleDictionary = Helpers.loadJSONFixture("module") as NSDictionary
        let module = CKIModule(fromJSONDictionary: moduleDictionary)
        let client = MockCKIClient()
        
        client.fetchModuleItemsForModule(module)
        XCTAssertEqual(client.capturedPath!, "/api/v1/modules/123/items", "CKIModuleItem returned API path for testFetchModuleItemsForModule was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIModuleItem API Interaction Method was incorrect ")
    }
}
