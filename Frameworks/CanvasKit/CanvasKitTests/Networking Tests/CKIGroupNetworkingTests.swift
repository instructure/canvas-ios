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

class CKIGroupNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchGroup() {
        let client = MockCKIClient()
        let groupID = "17"
        
        client.fetchGroup(groupID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/groups/17", "CKIGroup returned API path for testFetchGroup was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIGroup API Interaction Method was incorrect ")
    }
    
    func testfetchGroupsForLocalUser() {
        let client = MockCKIClient()
        
        client.fetchGroupsForLocalUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/groups", "CKIGroup returned API path for testfetchGroupsForLocalUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIGroup API Interaction Method was incorrect ")
    }
    
    /*
    func testFetchGroupsForAccount() {
        //TODO Not testible yet because CKIAccount hasn't been implemented
        let accountDictionary = Helpers.loadJSONFixture("account") as NSDictionary
        let account = CKIAccount(fromJSONDictionary: accountDictionary)
        let client = MockCKIClient()
        
        client.fetchGroupsForContext(account)
        XCTAssertEqual(client.capturedPath!, "/api/v1/accounts/1/groups", "CKIGroup returned API path for testFetchGroupsForAccount was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIGroup API Interaction Method was incorrect ")
    }
    */
    
    func testFetchGroupForContext() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        
        client.fetchGroup("17", forContext: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/groups/17", "CKIGroup returned API path for testFetchGroupForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIGroup API Interaction Method was incorrect ")
    }
    
    func testFetchGroupsForContext() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        
        client.fetchGroupsForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/groups", "CKIGroup returned API path for testFetchGroupsForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIGroup API Interaction Method was incorrect ")
    }
}
