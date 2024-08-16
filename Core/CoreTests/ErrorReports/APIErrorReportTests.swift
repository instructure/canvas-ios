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

class APIErroReportTests: CoreTestCase {
    let features = ExperimentalFeature.allCases.map { $0.isEnabled }

    override func setUp() {
        super.setUp()
        ExperimentalFeature.allEnabled = false
    }

    override func tearDown() {
        for (i, feature) in ExperimentalFeature.allCases.enumerated() {
            feature.isEnabled = features[i]
        }
        super.tearDown()
    }

    func testMinimalPostErrorReportRequest() {
        let min = PostErrorReportRequest(subject: "s", impact: 0).body!.error
        XCTAssertNil(min.category)
        XCTAssertNil(min.code)
        XCTAssertEqual(min.comments, """



        -----------------------------------
        User: 1
        Email:\u{0020}
        Hostname: https://canvas.instructure.com
        App Version: 1.0 (1)
        Platform: \(UIDevice.current.model)
        OS Version: \(UIDevice.current.systemVersion)
        -----------------------------------
        """)
        XCTAssertNil(min.description)
        XCTAssertEqual(min.email, currentSession.userEmail)
        XCTAssertEqual(min.http_env, [
            "User": "1",
            "Hostname": "https://canvas.instructure.com",
            "App Version": "1.0 (1)",
            "Platform": UIDevice.current.model,
            "OS Version": UIDevice.current.systemVersion
        ])
        XCTAssertNil(min.message)
        XCTAssertEqual(min.subject, "s [https://canvas.instructure.com]")
        XCTAssertEqual(min.url, currentSession.baseURL)
        XCTAssertEqual(min.user_perceived_severity, .just_a_comment)
    }

    func testMaximalPostErrorReportRequest() {
        let error = NSError(domain: "com.instructure", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Oops",
            "extra": "info"
        ])
        let max = PostErrorReportRequest(error: error, email: "me@example.com", subject: "s", impact: 4, comments: "comment").body!.error
        XCTAssertEqual(max.category, "com.instructure")
        XCTAssertEqual(max.code, 1)
        XCTAssertEqual(max.comments, """
        comment


        -----------------------------------
        User: 1
        Email: me@example.com
        Hostname: https://canvas.instructure.com
        App Version: 1.0 (1)
        Platform: \(UIDevice.current.model)
        OS Version: \(UIDevice.current.systemVersion)
        extra: info
        -----------------------------------
        """)
        XCTAssertNil(max.description)
        XCTAssertEqual(max.email, "me@example.com")
        XCTAssertEqual(max.http_env, [
            "User": "1",
            "Hostname": "https://canvas.instructure.com",
            "App Version": "1.0 (1)",
            "Platform": UIDevice.current.model,
            "OS Version": UIDevice.current.systemVersion,
            "extra": "info"
        ])
        XCTAssertEqual(max.message, "Oops")
        XCTAssertEqual(max.subject, "s [https://canvas.instructure.com]")
        XCTAssertEqual(max.url, currentSession.baseURL)
        XCTAssertEqual(max.user_perceived_severity, .extreme_critical_emergency)
    }

    func testExperimentalFeatures() {
        ExperimentalFeature.allEnabled = false
        let comments = PostErrorReportRequest(error: nil, email: "test@test.com", subject: "Experimental Features", impact: 1, comments: "Comments").body!.error.comments
        XCTAssertEqual(comments, """
        Comments


        -----------------------------------
        User: 1
        Email: test@test.com
        Hostname: https://canvas.instructure.com
        App Version: 1.0 (1)
        Platform: \(UIDevice.current.model)
        OS Version: \(UIDevice.current.systemVersion)
        -----------------------------------
        """)
    }
}
