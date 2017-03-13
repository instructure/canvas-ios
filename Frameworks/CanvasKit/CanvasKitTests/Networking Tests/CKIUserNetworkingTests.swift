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

class CKIUserNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testfetchUsersForContext() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        let dictionary = ["include": ["avatar_url", "enrollments"]];
        
        client.fetchUsersForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/users", "CKIUser returned API path for testfetchUsersForContext was incorrect")
        XCTAssertEqual(client.capturedParameters!.count, dictionary.count, "CKIUser returned API parameters for testfetchUsersForContext was incorrect")
    }

    func testFetchUsersWithParametersAndContext() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        let dictionary = ["include": ["avatar_url", "enrollments"]];
        
        client.fetchUsersWithParameters(dictionary, context: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/users", "CKIUser returned API path for testFetchUsersWithParametersAndContext was incorrect")
        XCTAssertEqual(client.capturedParameters!.count, dictionary.count, "CKIUser returned API parameters for testFetchUsersWithParametersAndContext was incorrect")
    }
    
    func testFetchCurrentUser() {
        let client = MockCKIClient()
        
        client.fetchCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/profile", "CKIUser returned API path for testFetchCurrentUser was incorrect")
    }
}
