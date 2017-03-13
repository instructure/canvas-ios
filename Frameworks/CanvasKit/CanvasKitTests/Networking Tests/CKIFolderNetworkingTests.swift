//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
