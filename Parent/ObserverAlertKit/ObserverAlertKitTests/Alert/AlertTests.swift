//
//  AlertTests.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 5/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

import CoreData
@testable import ObserverAlertKit
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
import AVFoundation

class AlertTests: XCTestCase {
    var alert: Alert!
    var session = Session.inMemory
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = try! session.alertsManagedObjectContext()
        alert = Alert.build(context)
    }

    func testIsValid() {
        XCTAssert(alert.isValid)
    }

    func testAlert_updateValues() {
        let session = Session.inMemory
        let context = try! session.alertsManagedObjectContext()
        var json = Alert.validJSON
        json["id"] = "id_1234"
        json["parent_id"] = "parent_id_1234"
        json["student_id"] = "student_id_1234"
        json["course_id"] = "course_id_1234"
        json["alert_threshold_id"] = "alert_threshold_id_1234"
        json["title"] = "title_1234"
        json["marked_read"] = false
        json["dismissed"] = false
        json["action_date"] = "2012-06-01T05:59:00Z"
        json["asset_url"] = "https://www.google.com"
        json["alert_type"] = "assignment_grade_high"

        let alert = Alert.create(inContext: context)
        try! alert.updateValues(json, inContext: context)

        XCTAssertEqual("id_1234", alert.id, "id should be set")
        XCTAssertEqual("parent_id_1234", alert.observerID, "parentID should be set")
        XCTAssertEqual("student_id_1234", alert.studentID, "studentID should be set")
        XCTAssertEqual("course_id_1234", alert.courseID, "courseID should be set")
        XCTAssertEqual("alert_threshold_id_1234", alert.thresholdID, "thresholdID should be set")
        XCTAssertEqual("title_1234", alert.title, "title should be set")
        XCTAssertEqual(false, alert.read, "read should be set")
        XCTAssertEqual(false, alert.dismissed, "dismissed should be set")
        XCTAssertEqual(AlertThresholdType.AssignmentGradeHigh, alert.type, "thresholdType should be set")
    }

    func testAlert_unknownAlertType() {
        let session = Session.inMemory
        let context = try! session.alertsManagedObjectContext()
        var json = Alert.validJSON
        json["alert_type"] = "unknown"

        let alert = Alert.create(inContext: context)
        try! alert.updateValues(json, inContext: context)

        XCTAssertEqual(AlertThresholdType.Unknown, alert.type, "thresholdType should be set")
    }
    
}
