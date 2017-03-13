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

class CKIModuleNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchModulesForCourse() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        
        client.fetchModulesForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/modules", "CKIModule returned API path for testFetchModulesForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIModule API Interaction Method was incorrect ")
    }

    func testFetchModuleWithIDForCourse() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        let moduleID = "768"
        
        client.fetchModuleWithID(moduleID, forCourse: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/modules/768", "CKIModule returned API path for testFetchModuleWithIDForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIModule API Interaction Method was incorrect ")
    }
}
