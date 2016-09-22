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
        let course = Course.build(context, id: "1")
        let grade = Grade.build(context, gradingPeriodID: nil, currentGrade: nil, course: { _ in return course })
        Grade.build(context, gradingPeriodID: "1", course: { _ in return course })
        try! context.save()

        getGrades("grades-list", course: course, gradingPeriodID: nil)

        context.refreshAllObjects()
        XCTAssertEqual(2, Grade.count(inContext: context))
        XCTAssertEqual("C", grade.currentGrade)
    }

    private func getGrades(fixture: Fixture, course: Course? = nil, gradingPeriodID: String?) -> [Grade]? {
        let course = course ?? Course.build(context)
        try! context.save()

        let refreshSignalProducer = try! Grade.refreshSignalProducer(session, courseID: course.id, gradingPeriodID: gradingPeriodID)
        var response: [Grade]?

        stub(session, fixture, timeout: 4) { expectation in
            refreshSignalProducer.startWithCompleted { expectation.fulfill() }
        }

        let fetch = Grade.fetch(Grade.predicate(course.id, gradingPeriodID: gradingPeriodID), sortDescriptors: nil, inContext: context)
        response = try? context.findAll(fromFetchRequest: fetch)

        return response
    }
}
