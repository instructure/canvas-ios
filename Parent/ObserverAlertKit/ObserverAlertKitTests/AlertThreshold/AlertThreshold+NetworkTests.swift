
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
    
    

@testable import ObserverAlertKit
import XCTest
import SoAutomated
import SoPersistent
import TooLegit
import DoNotShipThis
import Marshal
import Result

extension AlertThresholdTests {
    func testGetAllAlertThresholds() {
        let session = Session.parentTest

        var response: [JSONObject]?
        stub(session, "all-alert-thresholds") { expectation in
            try! AlertThreshold.getAllAlertThresholds(session).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }

        guard let alertThresholds = response, alertThreshold = alertThresholds.first where alertThresholds.count == 2 else {
            XCTFail("unexpected response")
            return
        }

        XCTAssert(alertThreshold.keys.contains("id"), "id should be set")
        XCTAssert(alertThreshold.keys.contains("parent_id"), "parent_id should be set")
        XCTAssert(alertThreshold.keys.contains("threshold"), "threshold should be set")
        XCTAssert(alertThreshold.keys.contains("alert_type"), "alert_type should be set")
        XCTAssert(alertThreshold.keys.contains("student_id"), "student_id should be set")
    }

    func testAlertThresholdNetwork_getAlertThresholdsByStudent() {
        let session = Session.parentTest

        let studentID = "16"

        var response: [JSONObject]?
        stub(session, "alert-thresholds-student") { expectation in
            try! AlertThreshold.getAlertThresholdsByStudent(session, studentID: studentID).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }

        guard let alertThresholds = response, alertThreshold = alertThresholds.first where alertThresholds.count == 1 else {
            XCTFail("unexpected response")
            return
        }

        XCTAssert(alertThreshold.keys.contains("id"), "id should be set")
        XCTAssert(alertThreshold.keys.contains("parent_id"), "parent_id should be set")
        XCTAssert(alertThreshold.keys.contains("threshold"), "threshold should be set")
        XCTAssert(alertThreshold.keys.contains("alert_type"), "alert_type should be set")
        XCTAssert(alertThreshold.keys.contains("student_id"), "student_id should be set")
    }

    func testInsertAlertThreshold() {
        let session = Session.parentTest

        let observerID = session.user.id
        let studentID = "16"
        let type = AlertThresholdType.AssignmentGradeHigh
        let threshold = "90"

        var response: JSONObject?
        stub(session, "insert-alert-threshold") { expectation in
            try! AlertThreshold.insertAlertThreshold(session, observerID: observerID, studentID: studentID, type: type.rawValue, threshold: threshold).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }

        guard let alertThreshold = response else {
            XCTFail("expected a response")
            return
        }

        XCTAssert(alertThreshold.keys.contains("id"), "id should be set")
        XCTAssert(alertThreshold.keys.contains("parent_id"), "parent_id should be set")
        XCTAssert(alertThreshold.keys.contains("threshold"), "threshold should be set")
        XCTAssert(alertThreshold.keys.contains("alert_type"), "alert_type should be set")
        XCTAssert(alertThreshold.keys.contains("student_id"), "student_id should be set")
    }

    func testUpdateAlertThreshold() {
        let session = Session.parentTest
        let context = try! session.alertsManagedObjectContext()

        let alertThreshold = AlertThreshold.build(context)
        var validJSON = AlertThreshold.validJSON
        validJSON["threshold"] = "85"
        try! alertThreshold.updateValues(validJSON, inContext: context)

        var response: JSONObject?
        stub(session, "update-alert-threshold") { expectation in
            try! alertThreshold.updateAlertThreshold(session, observerID: session.user.id).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }

        guard let json = response else {
            XCTFail("expected a response")
            return
        }

        XCTAssert(json.keys.contains("id"), "id should be set")
        XCTAssert(json.keys.contains("parent_id"), "parent_id should be set")
        XCTAssert(json.keys.contains("threshold"), "threshold should be set")
        XCTAssert(json.keys.contains("alert_type"), "alert_type should be set")
        XCTAssert(json.keys.contains("student_id"), "student_id should be set")
    }

    func testDeleteAlertThreshold() {

        let session = Session.parentTest
        let context = try! session.alertsManagedObjectContext()

        let alertThreshold = AlertThreshold.build(context)
        let json = AlertThreshold.validJSON
        try! alertThreshold.updateValues(json, inContext: context)

        stub(session, "delete-alert-threshold") { expectation in
            try! alertThreshold.deleteAlertThreshold(session, observerID: session.user.id).startWithCompletedExpectation(expectation) { _ in }
        }
    }

}
