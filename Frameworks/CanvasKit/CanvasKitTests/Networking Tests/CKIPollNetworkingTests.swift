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

class CKIPollNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchPollsForCurrentUser() {
        let client = MockCKIClient()
        
        client.fetchPollsForCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls", "CKIPoll returned API path for testFetchPollsForCurrentUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPoll API Interaction Method was incorrect")
    }

    func testFetchPollWithID() {
        let client = MockCKIClient()

        client.fetchPollWithID("1023")
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023", "CKIPoll returned API path for testFetchPollsForCurrentUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPoll API Interaction Method was incorrect")
    }

    func testCreatePoll() {
        let client = MockCKIClient()
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        client.createPoll(poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls", "CKIPoll returned API path for testFetchPollsForCurrentUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIPoll API Interaction Method was incorrect")
    }
    
    func testDeletePoll() {
        let client = MockCKIClient()
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        client.deletePoll(poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023", "CKIPoll returned API path for testDeletePoll was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Delete, "CKIPoll API Interaction Method was incorrect")
    }
}
