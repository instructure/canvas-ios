//
//  CourseSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 8/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Quick
import Nimble
import SoAutomated
import CoreData
@testable import EnrollmentKit
@testable import Canvas

class CourseSpec: QuickSpec {
    override func spec() {
        describe("Course") {
            describe("total grade") {
                var moc: NSManagedObjectContext!
                var course: Course!
                beforeEach {
                    moc = try! User(credentials: .user1).session.enrollmentManagedObjectContext()
                    course = Course.build(moc)
                }

                it("should be the grade without a score") {
                    let grade = Grade.build(moc, gradingPeriodID: course.currentGradingPeriodID, currentGrade: "A", currentScore: nil)
                    grade.course = course
                    expect(course.totalGrade(nil)) == "A"
                }

                it("should be the score without a grade") {
                    let grade = Grade.build(moc, gradingPeriodID: course.currentGradingPeriodID, currentGrade: nil, currentScore: 100)
                    grade.course = course
                    expect(course.totalGrade(nil)) == "100%"
                }

                it("should be the grade and score") {
                    let grade = Grade.build(moc, gradingPeriodID: course.currentGradingPeriodID, currentGrade: "A", currentScore: 100)
                    grade.course = course
                    expect(course.totalGrade(nil)) == "A  100%"
                }

                it("should be empty without grade and score") {
                    let grade = Grade.build(moc, gradingPeriodID: course.currentGradingPeriodID, currentGrade: nil, currentScore: nil)
                    grade.course = course
                    expect(course.totalGrade(nil)) == "-"
                }

                context("with multiple grading periods") {
                    var gradingPeriods: [GradingPeriod]!
                    beforeEach {
                        course.grades = [
                            Grade.build(moc, gradingPeriodID: "1", currentGrade: "A", currentScore: 100),
                            Grade.build(moc, gradingPeriodID: "2", currentGrade: "B", currentScore: 80),
                            Grade.build(moc, gradingPeriodID: "3", currentGrade: "C", currentScore: 70),
                        ]
                        gradingPeriods = [
                            GradingPeriod.build(moc, id: "1"),
                            GradingPeriod.build(moc, id: "2"),
                            GradingPeriod.build(moc, id: "3")
                        ]
                    }

                    it("should be the current grade without specifying grading period item") {
                        course.currentGradingPeriodID = "2"
                        expect(course.totalGrade(nil)) == "B  80%"
                    }

                    it("should be the grade for the grading period item") {
                        expect(course.totalGrade(GradingPeriodItem.Some(gradingPeriods[0]))) == "A  100%"
                        expect(course.totalGrade(GradingPeriodItem.Some(gradingPeriods[1]))) == "B  80%"
                    }

                    context("all") {
                        beforeEach {
                            let totalGradeForAllPeriods = Grade.build(moc, gradingPeriodID: nil, currentGrade: "D", currentScore: 65)
                            totalGradeForAllPeriods.course = course
                        }

                        it("should be the grade with a nil grading period id") {
                            course.totalForAllGradingPeriodsEnabled = true
                            expect(course.totalGrade(GradingPeriodItem.All)) == "D  65%"
                        }

                        it("should be empty without total for all grading periods enabled") {
                            course.totalForAllGradingPeriodsEnabled = false
                            expect(course.totalGrade(GradingPeriodItem.All)) == "-"
                        }
                    }
                }
            }
        }
    }
}
