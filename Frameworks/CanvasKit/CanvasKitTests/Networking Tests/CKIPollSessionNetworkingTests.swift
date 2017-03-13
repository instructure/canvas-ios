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

class CKIPollSessionNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchResultsForPollSession() {
        let pollSessionDictionary = Helpers.loadJSONFixture("poll_session") as NSDictionary
        let pollSession = CKIPollSession(fromJSONDictionary: pollSessionDictionary)
        let client = MockCKIClient()
        
        client.fetchResultsForPollSession(pollSession)
        XCTAssertEqual(client.capturedPath!, "/api/v1/poll_sessions/1023", "CKIPollSession returned API path for testFetchResultsForPollSession was incorrect")
    }

    func testFetchPollSessionsForPoll() {
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        let client = MockCKIClient()
        
        client.fetchPollSessionsForPoll(poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023/poll_sessions", "CKIPollSession returned API path for testFetchPollSessionsForPoll was incorrect")
    }

    func testFetchClosedPollSessionsForCurrentUser() {
        let client = MockCKIClient()
        
        client.fetchClosedPollSessionsForCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/poll_sessions/closed", "CKIPollSession returned API path for testFetchClosedPollSessionsForCurrentUser was incorrect")
    }

    func testFetchOpenPollSessionsForCurrentUser() {
        let client = MockCKIClient()
        
        client.fetchOpenPollSessionsForCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/poll_sessions/opened", "CKIPollSession returned API path for testFetchOpenPollSessionsForCurrentUser was incorrect")
    }
    
    func testCreatePollSessionForPoll() {
        let pollSessionDictionary = Helpers.loadJSONFixture("poll_session") as NSDictionary
        let pollSession = CKIPollSession(fromJSONDictionary: pollSessionDictionary)
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        let client = MockCKIClient()
        let dictionary = ["poll_sessions": [["course_id": pollSession.courseID], ["course_section_id": pollSession.sectionID]]];
        
        client.createPollSession(pollSession, forPoll: poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023/poll_sessions", "CKIPollSession returned API path for testCreatePollSessionForPoll was incorrect")
        XCTAssertEqual(client.capturedParameters!.count, dictionary.count, "CKIPollSession returned API parameters for testCreatePollSessionForPoll were incorrect")
    }

    func testDeletePollSession() {
        let pollSessionDictionary = Helpers.loadJSONFixture("poll_session") as NSDictionary
        let pollSession = CKIPollSession(fromJSONDictionary: pollSessionDictionary)
        let client = MockCKIClient()
        
        client.deletePollSession(pollSession)
        XCTAssertEqual(client.capturedPath!, pollSession.path, "CKIPollSession returned API path for testDeletePollSession was incorrect")
    }
    
    func testClosePollSession() {
        //TODO Not sure how to test this
    }
    
    func testPublishPollSession() {
        //TODO Not sure how to test this
    }
}
