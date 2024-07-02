//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Parent

class GetAlertThresholdRequestTests: XCTestCase {
    var req: GetAlertThresholdRequest!
    var studentID: String = "1"

    override func setUp() {
        super.setUp()
        req = GetAlertThresholdRequest(studentID: studentID)
    }

    func testPath() {
        XCTAssertEqual(req.path, "users/self/observer_alert_thresholds")
    }

    func testQuery() {
        let expected = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "student_id", value: studentID)
        ]
        XCTAssertEqual(req.queryItems, expected)
    }

	func testModel() {
		let model = APIAlertThreshold.make()
		XCTAssertNotNil(model)
	}
}

class DeleteAlertThresholdRequestTests: XCTestCase {
    var req: DeleteAlertThresholdRequest!
    var id: String = "1"

    override func setUp() {
        super.setUp()
        req = DeleteAlertThresholdRequest(thresholdID: id)
    }

    func testPath() {
        XCTAssertEqual(req.path, "users/self/observer_alert_thresholds/\(id)")
    }

    func testMethod() {
        XCTAssertEqual(req.method, .delete)
    }
}

class PutAlertThresholdRequestTests: XCTestCase {
    var req: PutAlertThresholdRequest!
    var id: String = "1"
    var alertType: AlertThresholdType = .assignmentGradeHigh

    override func setUp() {
        super.setUp()
        req = PutAlertThresholdRequest(thresholdID: id, alertType: alertType, value: 100)
    }

    func testPath() {
        XCTAssertEqual(req.path, "users/self/observer_alert_thresholds/\(id)")
    }

    func testBody() {
        let body = PutAlertThresholdRequest.Body(threshold: 100, alert_type: alertType)
        XCTAssertEqual(req.body, body)
    }

    func testMethod() {
        XCTAssertEqual(req.method, .put)
    }
}

class PostAlertThresholdRequestTests: XCTestCase {
    var req: PostAlertThresholdRequest!
    var userID: String = "1"
    var alertType: AlertThresholdType = .assignmentGradeHigh

    override func setUp() {
        super.setUp()
        req = PostAlertThresholdRequest(userID: userID, alertType: alertType, value: 100)
    }

    func testPath() {
        XCTAssertEqual(req.path, "users/self/observer_alert_thresholds")
    }

    func testBody() {
        let body = PostAlertThresholdRequest.Body(observer_alert_threshold: PostAlertThresholdRequest.AlertBody(user_id: userID, alert_type: alertType, threshold: 100))
        XCTAssertEqual(req.body, body)
    }
}
