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
    
    

import Foundation

import CoreData
@testable import ObserverAlertKit
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal

class AlertThresholdTests: XCTestCase {
    var alertThreshold: AlertThreshold!
    var session = Session.inMemory
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = try! session.alertsManagedObjectContext()
        alertThreshold = AlertThreshold.build(context)
    }

    func testIsValid() {
        XCTAssert(alertThreshold.isValid)
    }

    func testUpdateValues() {
        let session = Session.inMemory
        let context = try! session.alertsManagedObjectContext()
        var json = AlertThreshold.validJSON
        json["id"] = "id_1234"
        json["parent_id"] = "parent_id_1234"
        json["student_id"] = "student_id_1234"
        json["alert_type"] = "assignment_grade_high"
        json["threshold"] = "threshold_90"

        let alertThreshold: AlertThreshold = AlertThreshold.create(inContext: context)
        try! alertThreshold.updateValues(json, inContext: context)

        XCTAssertEqual("id_1234", alertThreshold.id, "id should be set")
        XCTAssertEqual("parent_id_1234", alertThreshold.observerID, "observerID should be set")
        XCTAssertEqual("student_id_1234", alertThreshold.studentID, "studentID should be set")
        XCTAssertEqual(AlertThresholdType.AssignmentGradeHigh, alertThreshold.type, "type should be set")
        XCTAssertEqual("threshold_90", alertThreshold.threshold, "threshold should be set")
    }

    func testAlertThresholdTypeOnDescriptions() {
        var threshold: AlertThresholdType = .CourseGradeLow
        XCTAssertEqual("Grade below", threshold.onDescription)

        threshold = .CourseGradeHigh
        XCTAssertEqual("Grade above", threshold.onDescription)

        threshold =.assignmentMissing
        XCTAssertEqual("Assignment missing", threshold.onDescription)

        threshold =.assignmentGradeLow
        XCTAssertEqual("Assignment grade below", threshold.onDescription)

        threshold =.assignmentGradeHigh
        XCTAssertEqual("Assignment grade above", threshold.onDescription)

        threshold = .InstitutionAnnouncement
        XCTAssertEqual("Institution announcements", threshold.onDescription)

        threshold = .CourseAnnouncement
        XCTAssertEqual("Course announcements", threshold.onDescription)

        threshold = .Unknown
        XCTAssertEqual("Unknown", threshold.onDescription)
    }

    func testAlertThresholdTypeOffDescriptions() {
        var threshold: AlertThresholdType = .CourseGradeLow
        XCTAssertEqual("Low course grade", threshold.offDescription)

        threshold = .CourseGradeHigh
        XCTAssertEqual("High course grade", threshold.offDescription)

        threshold =.assignmentMissing
        XCTAssertEqual("Assignment missing", threshold.offDescription)

        threshold =.assignmentGradeLow
        XCTAssertEqual("Low assignment grade", threshold.offDescription)

        threshold =.assignmentGradeHigh
        XCTAssertEqual("High assignment grade", threshold.offDescription)

        threshold = .InstitutionAnnouncement
        XCTAssertEqual("Institution announcements", threshold.offDescription)

        threshold = .CourseAnnouncement
        XCTAssertEqual("Course announcements", threshold.offDescription)

        threshold = .Unknown
        XCTAssertEqual("Unknown", threshold.offDescription)
    }

    func testAlertThresholdAllowsValues() {
        var threshold: AlertThresholdType = .CourseGradeLow
        XCTAssertEqual(true, threshold.allowsThresholdValue)

        threshold = .CourseGradeHigh
        XCTAssertEqual(true, threshold.allowsThresholdValue)

        threshold =.assignmentMissing
        XCTAssertEqual(false, threshold.allowsThresholdValue)

        threshold =.assignmentGradeLow
        XCTAssertEqual(true, threshold.allowsThresholdValue)

        threshold =.assignmentGradeHigh
        XCTAssertEqual(true, threshold.allowsThresholdValue)

        threshold = .InstitutionAnnouncement
        XCTAssertEqual(false, threshold.allowsThresholdValue)

        threshold = .CourseAnnouncement
        XCTAssertEqual(false, threshold.allowsThresholdValue)

        threshold = .Unknown
        XCTAssertEqual(false, threshold.allowsThresholdValue)
    }
}
