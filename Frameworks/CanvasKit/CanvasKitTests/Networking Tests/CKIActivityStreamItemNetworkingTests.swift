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

class CKIActivityStreamItemNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchActivityStream() {
        var client = MockCKIClient()
        client.fetchActivityStream()
        if client.capturedPath? != nil {
             XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/activity_stream", "Returned API path for testFetchActivityStream was incorrect")
        } else {
            XCTAssertNotNil(client.capturedPath, "CKIActivityStreamItem path was not initialized in CKIClient")
        }
    }
    
    func testFetchActivityStreamForContext() {
        var client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        client.fetchActivityStreamForContext(course)
        if client.capturedPath? != nil{
            XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/activity_stream", "Returned API path for testFetchActivityStreamForContext was incorrect")
        } else {
            XCTAssertNotNil(client.capturedPath, "CKIActivityStreamItem path was not initialized in CKIClient")
        }
    }
}
