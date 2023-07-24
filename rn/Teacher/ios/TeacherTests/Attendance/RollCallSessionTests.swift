//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core
@testable import Teacher
import TestsFoundation

class RollCallSessionTests: TeacherTestCase, RollCallSessionDelegate {
    lazy var finished: XCTestExpectation = {
        let expect = expectation(description: "Finished loading")
        expect.assertForOverFulfill = false
        return expect
    }()

    func session(_ session: RollCallSession, didFailWithError error: Error) {
        finished.fulfill()
    }

    func sessionDidBecomeActive(_ session: RollCallSession) {
        finished.fulfill()
    }

    let context = Context(.course, id: "1")
    lazy var launchRequest = GetSessionlessLaunchURLRequest(context: context,
                                                            id: "2",
                                                            url: nil,
                                                            assignmentID: nil,
                                                            moduleItemID: nil,
                                                            launchType: .course_navigation,
                                                            resourceLinkLookupUUID: nil)

    lazy var session: RollCallSession = {
        let session = RollCallSession(context: context, toolID: "2", delegate: self)
        session.baseURL = URL(string: "data:text/plain,")!
        session.start()
        wait(for: [finished], timeout: 10)
        return session
    }()

    func testLaunchFail() {
        api.mock(launchRequest, error: NSError.internalError())
        switch session.state {
        case .error(let error):
            XCTAssertEqual((error as NSError).domain, "com.instructure.rollcall")
            XCTAssertEqual(error.localizedDescription, "Failed to launch rollcall LTI tool.")
        default:
            XCTFail("Session loading should have failed")
        }
    }

    func testLaunchNoData() {
        api.mock(launchRequest, value: .make(url: URL(string: "data:text/plain,")!))
        session.launch(url: URL(string: "data:text/plain,")!)
        switch session.state {
        case .error(let error):
            XCTAssertEqual((error as NSError).domain, "com.instructure.rollcall")
            XCTAssertEqual(error.localizedDescription, "Error: No data returned from the rollcall api.")
        default:
            XCTFail("Session loading should have failed")
        }
    }

    func testLaunchError() {
        let data = "<pre>Error</pre>".data(using: .utf8)!
        let url = URL(string: "data:text/html;base64,\(data.base64EncodedString())")!
        api.mock(launchRequest, value: .make(url: url))
        switch session.state {
        case .error(let error):
            XCTAssertEqual((error as NSError).domain, "com.instructure.rollcall")
            XCTAssertEqual(error.localizedDescription, "Error")
        default:
            XCTFail("Session loading should have failed")
        }
    }

    func testLaunchSuccess() {
        let data = "<meta name=\"csrf-token\" content=\"xsrf\">".data(using: .utf8)!
        let url = URL(string: "data:text/html;base64,\(data.base64EncodedString())")!
        api.mock(launchRequest, value: .make(url: url))
        switch session.state {
        case .active(let api):
            XCTAssertEqual(api.urlSession.configuration.httpAdditionalHeaders?["X-CSRF-Token"] as? String, "xsrf")
        default:
            XCTFail("Session loading should not have failed")
        }
    }

    func testFetchStatuses() {
        let date = DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 10, day: 31).date!

        session.baseURL = URL(string: "https://rollcall.instructure.com")!
        let url = URL(string: "/statuses?section_id=1&class_date=2019-10-31", relativeTo: session.baseURL)!

        session.fetchStatuses(section: "1", date: date) { (statuses, error) in
            XCTAssert(statuses.isEmpty)
            XCTAssertNil(error)
        }
        session.state = .active(API())
        api.mock(URLRequest(url: url))
        session.fetchStatuses(section: "1", date: date) { (statuses, error) in
            XCTAssert(statuses.isEmpty)
            XCTAssertEqual(error?.localizedDescription, "Error: No data returned from the rollcall api.")
        }

        api.mock(URLRequest(url: url), data: Data())
        session.fetchStatuses(section: "1", date: date) { (statuses, error) in
            XCTAssert(statuses.isEmpty)
            XCTAssertNotNil(error)
        }

        let status = Status.make()
        api.mock(URLRequest(url: url), data: try? session.encoder.encode([status]))
        session.fetchStatuses(section: "1", date: date) { (statuses, error) in
            XCTAssertEqual(statuses.count, 1)
            XCTAssertNil(error)
        }
    }

    func testUpdateStatus() {
        session.baseURL = URL(string: "https://rollcall.instructure.com")!
        let url = URL(string: "/statuses", relativeTo: session.baseURL)!

        session.updateStatus(.make(id: nil)) { (id, error) in
            XCTAssertNil(id)
            XCTAssertNil(error)
        }

        session.state = .active(API())
        api.mock(URLRequest(url: url))
        session.updateStatus(.make(id: nil)) { (id, error) in
            XCTAssertNil(id)
            XCTAssertEqual(error?.localizedDescription, "Error: No data returned from the rollcall api.")
        }

        api.mock(URLRequest(url: url.appendingPathComponent("1")), data: Data())
        session.updateStatus(.make(attendance: .present)) { (id, error) in
            XCTAssertNil(id)
            XCTAssertNotNil(error)
        }

        api.mock(URLRequest(url: url.appendingPathComponent("1")), data: Data())
        session.updateStatus(.make(attendance: nil)) { (id, error) in
            XCTAssertNil(id)
            XCTAssertNil(error)
        }

        api.mock(URLRequest(url: url.appendingPathComponent("1")), data: try? session.encoder.encode(Status.make()))
        session.updateStatus(.make(attendance: .present)) { (id, error) in
            XCTAssertEqual(id?.value, "1")
            XCTAssertNil(error)
        }
    }
}
