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

class CKIPageNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchPagesForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchPagesForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/pages", "CKIPage returned API path for testFetchPagesForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPage API Interaction Method was incorrect")
    }

    func testFetchPageForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let pageID = "1"
        
        client.fetchPage(pageID, forContext: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/pages/1", "CKIPage returned API path for testFetchPageForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPage API Interaction Method was incorrect")
    }

    func testFetchFrontPageForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchFrontPageForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/front_page", "CKIPage returned API path for testFetchFrontPageForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPage API Interaction Method was incorrect")
    }
}
