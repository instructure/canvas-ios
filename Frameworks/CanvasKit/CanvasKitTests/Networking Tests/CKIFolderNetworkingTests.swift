//
//  CKIFolderNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIFolderNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchFolder() {
        let client = MockCKIClient()
        let folderID = "2937"
        
        client.fetchFolder(folderID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/folders/2937", "CKIFolder returned API path for testFetchFolder was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIFolder API Interaction Method was incorrect ")
    }

    func testFetchRootFolderForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchRootFolderForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/folders/root", "CKIFolder returned API path for testFetchRootFolderForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIFolder API Interaction Method was incorrect ")
    }
    
    func testFetchFoldersForFolder() {
        let client = MockCKIClient()
        let folderDictionary = Helpers.loadJSONFixture("folder") as NSDictionary
        let folder = CKIFolder(fromJSONDictionary: folderDictionary)
        
        client.fetchFoldersForFolder(folder)
        XCTAssertEqual(client.capturedPath!, "/api/v1/folders/2937/folders", "CKIFolder returned API path for testFetchFoldersForFolder was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIFolder API Interaction Method was incorrect ")
    }
    
    func testFetchFilesForFolder() {
        let client = MockCKIClient()
        let folderDictionary = Helpers.loadJSONFixture("folder") as NSDictionary
        let folder = CKIFolder(fromJSONDictionary: folderDictionary)
        
        client.fetchFilesForFolder(folder)
        XCTAssertEqual(client.capturedPath!, "/api/v1/folders/2937/files", "CKIFolder returned API path for testFetchFoldersForFolder was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIFolder API Interaction Method was incorrect ")
    }
    
    func testFetchFolderWithContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let folderID = "2937"
        
        client.fetchFolder(folderID, withContext: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/folders/2937", "CKIFolder returned API path for testFetchFolderWithContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIFolder API Interaction Method was incorrect ")
    }

    func testDeleteFolder() {
        let client = MockCKIClient()
        let folderDictionary = Helpers.loadJSONFixture("folder") as NSDictionary
        let folder = CKIFolder(fromJSONDictionary: folderDictionary)
        
        client.deleteFolder(folder)
        XCTAssertEqual(client.capturedPath!, "/api/v1/folders/2937", "CKIFolder returned API path for testDeleteFolder was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Delete, "CKIFolder API Interaction Method was incorrect ")
    }
    
    func testCreateFolderInFolder() {
        let client = MockCKIClient()
        let folderDictionary = Helpers.loadJSONFixture("folder") as NSDictionary
        let folder = CKIFolder(fromJSONDictionary: folderDictionary)
        
        client.createFolder(folder, inFolder: folder)
        XCTAssertEqual(client.capturedPath!, "/api/v1/folders/2937/folders", "CKIFolder returned API path for testCreateFolderInFolder was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIFolder API Interaction Method was incorrect ")
    }
}
