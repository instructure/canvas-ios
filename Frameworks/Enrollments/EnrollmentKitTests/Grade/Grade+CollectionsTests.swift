//
//  Grade+CollectionsTests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/19/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

@testable import EnrollmentKit
import SoAutomated
import XCTest
import TooLegit
import DoNotShipThis
import Result
import ReactiveCocoa
import CoreData

class GradeCollectionsTests: XCTestCase {
    let session = Session.na_mgp
    lazy var context: NSManagedObjectContext = {
        return try! self.session.enrollmentManagedObjectContext()
    }()

    func testRefreshSignalProducer() {
        let response = getGrades("grades-list", gradingPeriodID: nil)

        guard let grades = response, grade = grades.first where grades.count == 1 else {
            XCTFail("unexpected response: \(response)")
            return
        }

        XCTAssertEqual(75, grade.currentScore)
        XCTAssertEqual("C", grade.currentGrade)
        XCTAssertEqual(75, grade.finalScore)
        XCTAssertEqual("C", grade.finalGrade)
        XCTAssertEqual("1", grade.course.id)
        XCTAssertNil(grade.gradingPeriodID)
    }

    func testRefreshSignalProducerWithGradingPeriodID() {
        let response = getGrades("grading-period-grades-list", gradingPeriodID: "1")

        guard let grades = response, grade = grades.first where grades.count == 1 else {
            XCTFail("unexpected response: \(response)")
            return
        }

        XCTAssertEqual("1", grade.gradingPeriodID)
    }

    func testRefreshSignalProducerUpdatesLocalGrades() {
        let course = Course.build(inSession: session) { $0.id = "1" }
        let grade = Grade.build(inSession: session) {
            $0.gradingPeriodID = nil
            $0.currentGrade = nil
            $0.course = course
        }
        Grade.build(inSession: session) {
            $0.gradingPeriodID = "1"
            $0.course = course
        }

        getGrades("grades-list", course: course, gradingPeriodID: nil)

        context.refreshAllObjects()
        XCTAssertEqual(2, Grade.count(inContext: context))
        XCTAssertEqual("C", grade.currentGrade)
    }

    private func getGrades(fixture: String, course: Course? = nil, gradingPeriodID: String?) -> [Grade]? {
        let course = course ?? Course.build(inSession: session)

        let refreshSignalProducer = try! Grade.refreshSignalProducer(session, courseID: course.id, gradingPeriodID: gradingPeriodID)
        var response: [Grade]?

        session.playback(fixture, in: currentBundle) {
            refreshSignalProducer.startAndWaitForCompleted()
        }

        let fetch = Grade.fetch(Grade.predicate(course.id, gradingPeriodID: gradingPeriodID), sortDescriptors: nil, inContext: context)
        response = try? context.findAll(fromFetchRequest: fetch)

        return response
    }
}
