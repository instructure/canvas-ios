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
    
    

@testable import EnrollmentKit
import Quick
import Nimble
import SoAutomated
import CoreData
import Marshal
import TooLegit
import ReactiveSwift

let currentBundle = Bundle(for: CourseSpec.self)

class CourseSpec: QuickSpec {
    override func spec() {
        describe("Course") {
            var user: User!
            var managedObjectContext: NSManagedObjectContext!
            var course: Course!

            beforeEach {
                user = User(credentials: .user1)
                managedObjectContext = try! user.session.enrollmentManagedObjectContext()
                course = Course.build(inSession: user.session)
            }

            it("has grades") {
                expect(course.hasGrades) == true
            }

            it("has a short name") {
                course.code = "short_name"
                expect(course.shortName) == "short_name"
            }

            it("finds grades by grading period id") {
                Grade.build(inSession: user.session) {
                    $0.gradingPeriodID = nil
                    $0.currentGrade = "A"
                    $0.course = course
                }
                Grade.build(inSession: user.session) {
                    $0.gradingPeriodID = "1"
                    $0.currentGrade = "B"
                    $0.course = course
                }
                Grade.build(inSession: user.session) {
                    $0.gradingPeriodID = "2"
                    $0.currentGrade = "C"
                    $0.course = course
                }

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
                Grade.build(inSession: user.session) {
                    $0.gradingPeriodID = nil
                    $0.currentScore = 100
                    $0.course = course
                }
                Grade.build(inSession: user.session) {
                    $0.gradingPeriodID = "1"
                    $0.currentScore = 80
                    $0.course = course
                }
                Grade.build(inSession: user.session) {
                    $0.gradingPeriodID = "2"
                    $0.currentScore = 70
                    $0.course = course
                }

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
                    Grade.build(inSession: user.session) {
                        $0.gradingPeriodID = "1"
                        $0.currentGrade = "A"
                        $0.course = course
                    }
                    course.currentGradingPeriodID = "2"
                    expect(course.visibleGrade).to(beNil())
                    expect(course.visibleScore).to(beNil())
                }

                it("is the current grade/score for the current grading period") {
                    Grade.build(inSession: user.session) {
                        $0.gradingPeriodID = nil
                        $0.currentGrade = "A"
                        $0.currentScore = 100
                        $0.course = course
                    }
                    Grade.build(inSession: user.session) {
                        $0.gradingPeriodID = "1"
                        $0.currentGrade = "B"
                        $0.currentScore = 80
                        $0.course = course
                    }

                    course.currentGradingPeriodID = nil
                    expect(course.visibleGrade) == "A"
                    expect(course.visibleScore) == "100%"

                    course.currentGradingPeriodID = "1"
                    expect(course.visibleGrade) == "B"
                    expect(course.visibleScore) == "80%"
                }

                it("is nil when effected by totalForAllGradingPeriodsEnabled") {
                    course.multipleGradingPeriodsEnabled = true
                    course.currentGradingPeriodID = nil
                    course.totalForAllGradingPeriodsEnabled = false
                    Grade.build(inSession: user.session) {
                        $0.gradingPeriodID = nil
                        $0.currentGrade = "A"
                        $0.currentScore = 100
                        $0.course = course
                    }
                    Grade.build(inSession: user.session) {
                        $0.gradingPeriodID = "1"
                        $0.currentGrade = "B"
                        $0.currentScore = 80
                        $0.course = course
                    }
                    expect(course.visibleGrade).to(beNil())
                    expect(course.visibleScore).to(beNil())

                    course.totalForAllGradingPeriodsEnabled = true
                    expect(course.visibleGrade) == "A"
                    expect(course.visibleScore) == "100%"

                    course.totalForAllGradingPeriodsEnabled = false
                    course.currentGradingPeriodID = "1"
                    expect(course.visibleGrade) == "B"
                    expect(course.visibleScore) == "80%"
                }
            }

            describe("update values") {
                it("handles invalid enrollment types") {
                    var json = self.validCourseJSON
                    json["enrollments"] = [["type": "invalid"]]
                    try! course.updateValues(json, inContext: managedObjectContext)
                    expect { try course.updateValues(json, inContext: managedObjectContext) }.notTo(throwError())
                }

                context("when valid") {
                    beforeEach {
                        try! course.updateValues(self.validCourseJSON, inContext: managedObjectContext)
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
                        try! course.updateValues(self.mgpCourseJSON, inContext: managedObjectContext)
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
                    try! course.updateValues(self.validCourseJSON, inContext: managedObjectContext)
                }

                context("when it works") {
                    beforeEach {
                        course.id = "1867097"
                    }

                    it("adds favorite") {
                        course.isFavorite = false
                        user.session.playback("CourseMarkAsFavoriteAddsFavorite", in: currentBundle) {
                            course.markAsFavorite(true, session: user.session).startAndWaitForCompleted()
                        }
                        expect(course.isFavorite) == true
                    }

                    it("removes favorite") {
                        course.isFavorite = true
                        user.session.playback("CourseMarkAsFavoriteRemovesFavorite", in: currentBundle) {
                            course.markAsFavorite(false, session: user.session).startAndWaitForCompleted()
                        }
                        expect(course.isFavorite) == false
                    }
                }

                context("when it doesnt work") {
                    beforeEach {
                        course.id = "not_a_real_course"
                    }

                    it("sends errors") {
                        var error: NSError?
                        user.session.playback("CourseMarkAsFavoriteSendsErrors", in: currentBundle) {
                            course.markAsFavorite(true, session: user.session).startAndWaitForFailed { error = $0 }
                        }
                        expect(error).toNot(beNil())
                    }

                    it("resets isFavorite") {
                        course.isFavorite = false
                        user.session.playback("CourseMarkAsFavoriteSendsErrors", in: currentBundle) {
                            course.markAsFavorite(true, session: user.session).startAndWaitForFailed()
                        }
                        expect(course.isFavorite) == false
                    }
                }
            }

            describe("getAllCourses") {
                it("should filter out pending enrollments") {
                    let session = User(credentials: .user3).session
                    var courses: [JSONObject]?
                    session.playback("CoursesWithPendingEnrollments", in: currentBundle) {
                        waitUntil { done in
                            try! Course.getAllCourses(session)
                                .take(first: 1)
                                .on(value: { courses = $0 })
                                .startWithCompleted { done() }
                        }
                    }
                    expect(courses).toNot(beNil())
                    expect(courses).to(haveCount(1))
                }
            }
        }
    }
}
