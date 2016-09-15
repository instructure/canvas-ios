//
//  CourseSpec.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 7/19/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

@testable import EnrollmentKit
import Quick
import Nimble
import SoAutomated
import CoreData
import Marshal
import TooLegit
import ReactiveCocoa

class CourseSpec: QuickSpec {
    override func spec() {
        describe("Course") {
            var user: User!
            var managedObjectContext: NSManagedObjectContext!
            var course: Course!

            beforeEach {
                user = User(credentials: .user1)
                managedObjectContext = try! user.session.enrollmentManagedObjectContext()
                course = Course.create(inContext: managedObjectContext)
            }

            it("has grades") {
                expect(course.hasGrades) == true
            }

            it("has a short name") {
                course.code = "short_name"
                expect(course.shortName) == "short_name"
            }

            it("finds grades by grading period id") {
                Grade.build(managedObjectContext, gradingPeriodID: nil, currentGrade: "A", course: { _ in course })
                Grade.build(managedObjectContext, gradingPeriodID: "1", currentGrade: "B", course: { _ in course })
                Grade.build(managedObjectContext, gradingPeriodID: "2", currentGrade: "C", course: { _ in course })

                let a = course.visibleGradingPeriodGrade(nil)
                let b = course.visibleGradingPeriodGrade("1")
                let c = course.visibleGradingPeriodGrade("2")
                let doesNotExist = course.visibleGradingPeriodGrade("3")

                expect(a) == "A"
                expect(b) == "B"
                expect(c) == "C"
                expect(doesNotExist).to(beNil())
            }

            it("finds scores by grading period id") {
                Grade.build(managedObjectContext, gradingPeriodID: nil, currentScore: 100, course: { _ in course })
                Grade.build(managedObjectContext, gradingPeriodID: "1", currentScore: 80, course: { _ in course })
                Grade.build(managedObjectContext, gradingPeriodID: "2", currentScore: 70, course: { _ in course })

                let a = course.visibleGradingPeriodScore(nil)
                let b = course.visibleGradingPeriodScore("1")
                let c = course.visibleGradingPeriodScore("2")
                let doesNotExist = course.visibleGradingPeriodScore("3")

                expect(a) == "100%"
                expect(b) == "80%"
                expect(c) == "70%"
                expect(doesNotExist).to(beNil())
            }

            describe("visible grade/score") {
                beforeEach {
                    course.grades = []
                }

                it("is nil if there are no grades") {
                    expect(course.visibleGrade).to(beNil())
                    expect(course.visibleScore).to(beNil())
                }

                it("is nil if there are no grades for the current grading period") {
                    Grade.build(managedObjectContext, gradingPeriodID: "1", currentGrade: "A", course: { _ in course })
                    course.currentGradingPeriodID = "2"
                    expect(course.visibleGrade).to(beNil())
                    expect(course.visibleScore).to(beNil())
                }

                it("is the current grade/score for the current grading period") {
                    Grade.build(managedObjectContext, gradingPeriodID: nil, currentGrade: "A", currentScore: 100, course: { _ in course })
                    Grade.build(managedObjectContext, gradingPeriodID: "1", currentGrade: "B", currentScore: 80, course: { _ in course })

                    course.currentGradingPeriodID = nil
                    expect(course.visibleGrade) == "A"
                    expect(course.visibleScore) == "100%"

                    course.currentGradingPeriodID = "1"
                    expect(course.visibleGrade) == "B"
                    expect(course.visibleScore) == "80%"
                }
            }

            describe("update values") {
                it("handles invalid enrollment types") {
                    var json = self.validCourseJSON
                    json["enrollments"] = [["type": "invalid"]]
                    self.attempt { try course.updateValues(json, inContext: managedObjectContext) }
                    expect { try course.updateValues(json, inContext: managedObjectContext) }.notTo(throwError())
                }

                context("when valid") {
                    beforeEach {
                        self.attempt {
                            try course.updateValues(self.validCourseJSON, inContext: managedObjectContext)
                        }
                    }

                    it("creates a valid course") {
                        expect(course.isValid) == true
                    }

                    it("updates values") {
                        expect(course.id) == "1"
                        expect(course.name) == "Course 1"
                        expect(course.code) == "xyz"
                        expect(course.isFavorite) == true
                        expect(course.hideFinalGrades) == false
                        expect(course.defaultViewPath) == "courses/1/activity_stream"
                        expect(course.roles) == [.Student, .Teacher, .Observer, .TA, .Designer]
                        expect(course.multipleGradingPeriodsEnabled) == false
                        expect(course.currentGradingPeriodID).to(beNil())
                    }

                    it("sets the current grade") {
                        let grade = course.currentGrade
                        expect(grade) != nil
                        expect(grade?.gradingPeriodID).to(beNil())
                        expect(grade?.currentGrade) == "A"
                        expect(grade?.currentScore) == 100
                        expect(grade?.finalGrade) == "B"
                        expect(grade?.finalScore) == 80
                    }

                    it("sets totalForAllGradingPeriodsEnabled to false by default") {
                        expect(course.totalForAllGradingPeriodsEnabled) == false
                    }
                }

                context("when mgp enabled") {
                    beforeEach {
                        self.attempt {
                            try course.updateValues(self.mgpCourseJSON, inContext: managedObjectContext)
                        }
                    }

                    it("sets the current grade") {
                        let grade = course.currentGrade
                        expect(grade) != nil
                        expect(grade?.currentGrade) == "F"
                        expect(grade?.currentScore) == 50
                        expect(grade?.finalGrade) == "D"
                        expect(grade?.finalScore) == 60
                    }

                    it("sets the current grading period id") {
                        expect(course.currentGradingPeriodID) == "1"
                    }

                    it("sets multipleGradingPeriodsEnabled") {
                        expect(course.multipleGradingPeriodsEnabled) == true
                    }

                    it("sets totalForAllGradingPeriodsEnabled") {
                        expect(course.totalForAllGradingPeriodsEnabled) == true
                    }
                }
            }

            describe("default view path") {
                beforeEach {
                    course.id = "1"
                }

                it("defaults to activity stream") {
                    expect(course.defaultViewPath) == "courses/1/activity_stream"
                }

                it("converts raw values to path") {
                    course.rawDefaultView = "feed"
                    expect(course.defaultViewPath) == "courses/1/activity_stream"

                    course.rawDefaultView = "wiki"
                    expect(course.defaultViewPath) == "courses/1/front_page"

                    course.rawDefaultView = "modules"
                    expect(course.defaultViewPath) == "courses/1/modules"

                    course.rawDefaultView = "assignments"
                    expect(course.defaultViewPath) == "courses/1/assignments"

                    course.rawDefaultView = "syllabus"
                    expect(course.defaultViewPath) == "courses/1/syllabus"
                }
            }

            describe("mark as favorite") {
                beforeEach {
                    // marking as favorite does a save so we need a valid course
                    self.attempt { try course.updateValues(self.validCourseJSON, inContext: managedObjectContext) }
                }

                context("when it works") {
                    beforeEach {
                        course.id = "1867097"
                    }

                    it("adds favorite") {
                        let stub = Stub(session: user.session, name: "CourseMarkAsFavoriteAddsFavorite", testCase: self, bundle: NSBundle(forClass: CourseSpec.self))
                        course.isFavorite = false
                        course.markAsFavorite(true, session: user.session).startWithStub(stub)
                        expect(course.isFavorite) == true
                    }

                    it("removes favorite") {
                        let stub = Stub(session: user.session, name: "CourseMarkAsFavoriteRemovesFavorite", testCase: self, bundle: NSBundle(forClass: CourseSpec.self))
                        course.isFavorite = true
                        course.markAsFavorite(false, session: user.session).startWithStub(stub)
                        expect(course.isFavorite) == false
                    }
                }

                context("when it doesnt work") {
                    var stub: Stub!
                    beforeEach {
                        course.id = "not_a_real_course"
                        stub = Stub(session: user.session, name: "CourseMarkAsFavoriteSendsErrors", testCase: self, bundle: NSBundle(forClass: CourseSpec.self))
                    }

                    it("sends errors") {
                        var error: NSError?
                        self.performNetworkRequests(with: stub) { expectation in
                            course.markAsFavorite(true, session: user.session).startWithFailedExpectation(expectation) { error = $0 }
                        }
                        expect(error).toNot(beNil())
                    }

                    it("resets isFavorite") {
                        course.isFavorite = false
                        self.performNetworkRequests(with: stub) { expectation in
                            course.markAsFavorite(true, session: user.session).startWithFailedExpectation(expectation)
                        }
                        expect(course.isFavorite) == false
                    }
                }
            }
        }

    }
}
