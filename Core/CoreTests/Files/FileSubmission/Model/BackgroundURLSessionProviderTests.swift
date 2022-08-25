//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
import Core

class BackgroundURLSessionProviderTests: XCTestCase {
    private var testee: BackgroundURLSessionProvider!

    override func setUp() {
        super.setUp()
        testee = BackgroundURLSessionProvider(sessionID: "testSession", sharedContainerID: "testContainer")
    }

    func testURLSessionProperties() {
        let session = testee.session
        XCTAssertEqual(session.configuration.sharedContainerIdentifier, "testContainer")
        XCTAssertEqual(session.configuration.identifier, "testSession")
    }

    func testCachesURLSession() {
        let session1 = testee.session
        let session2 = testee.session
        XCTAssertEqual(session1, session2)
    }

    func testCallesCompletionHandlerWhenSessionFinishes() {
        let completionCalled = expectation(description: "completion handler called")
        testee.completionHandler = {
            completionCalled.fulfill()
        }
        let session = testee.session
        testee.urlSessionDidFinishEvents(forBackgroundURLSession: session)
        waitForExpectations(timeout: 0.1)
    }

    func testCreatesNewSessionIfSessionBecameInvalid() {
        let oldSession = testee.session
        oldSession.invalidateAndCancel()
        drainMainQueue()
        let newSession = testee.session
        XCTAssertNotEqual(oldSession, newSession)
    }
}
