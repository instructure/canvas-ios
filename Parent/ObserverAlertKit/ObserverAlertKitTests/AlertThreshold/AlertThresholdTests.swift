//
//  AlertThresholdTests.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

        threshold = .AssignmentMissing
        XCTAssertEqual("Assignment missing", threshold.onDescription)

        threshold = .AssignmentGradeLow
        XCTAssertEqual("Assignment grade below", threshold.onDescription)

        threshold = .AssignmentGradeHigh
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

        threshold = .AssignmentMissing
        XCTAssertEqual("Assignment missing", threshold.offDescription)

        threshold = .AssignmentGradeLow
        XCTAssertEqual("Low assignment grade", threshold.offDescription)

        threshold = .AssignmentGradeHigh
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

        threshold = .AssignmentMissing
        XCTAssertEqual(false, threshold.allowsThresholdValue)

        threshold = .AssignmentGradeLow
        XCTAssertEqual(true, threshold.allowsThresholdValue)

        threshold = .AssignmentGradeHigh
        XCTAssertEqual(true, threshold.allowsThresholdValue)

        threshold = .InstitutionAnnouncement
        XCTAssertEqual(false, threshold.allowsThresholdValue)

        threshold = .CourseAnnouncement
        XCTAssertEqual(false, threshold.allowsThresholdValue)

        threshold = .Unknown
        XCTAssertEqual(false, threshold.allowsThresholdValue)
    }
}
