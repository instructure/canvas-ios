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
    
    

import Quick
import Nimble
import SoAutomated
import CoreData
import TooLegit
@testable import EnrollmentKit
@testable import Canvas

class CourseSpec: QuickSpec {
    override func spec() {
        describe("Course") {
            describe("total grade") {
                var session: Session!
                var course: Course!
                beforeEach {
                    session = User(credentials: .user1).session
                    course = Course.build(inSession: session)
                }

                it("should be the grade without a score") {
                    let grade = Grade.build(inSession: session) {
                        $0.gradingPeriodID = course.currentGradingPeriodID
                        $0.currentGrade = "A"
                        $0.currentScore = nil
                    }
                    grade.course = course
                    expect(course.totalGrade(nil)) == "A"
                }

                it("should be the score without a grade") {
                    let grade = Grade.build(inSession: session) {
                        $0.gradingPeriodID = course.currentGradingPeriodID
                        $0.currentGrade = nil
                        $0.currentScore = 100
                    }
                    grade.course = course
                    expect(course.totalGrade(nil)) == "100%"
                }

                it("should be the grade and score") {
                    let grade = Grade.build(inSession: session) {
                        $0.gradingPeriodID = course.currentGradingPeriodID
                        $0.currentGrade = "A"
                        $0.currentScore = 100
                    }
                    grade.course = course
                    expect(course.totalGrade(nil)) == "A  100%"
                }

                it("should be empty without grade and score") {
                    let grade = Grade.build(inSession: session) {
                        $0.gradingPeriodID = course.currentGradingPeriodID
                        $0.currentGrade = nil
                        $0.currentScore = nil
                    }
                    grade.course = course
                    expect(course.totalGrade(nil)) == "-"
                }

                context("with multiple grading periods") {
                    var gradingPeriods: [GradingPeriod]!
                    beforeEach {
                        course.grades = [
                            Grade.build(inSession: session) {
                                $0.gradingPeriodID = "1"
                                $0.currentGrade = "A"
                                $0.currentScore = 100
                            },
                            Grade.build(inSession: session) {
                                $0.gradingPeriodID = "2"
                                $0.currentGrade = "B"
                                $0.currentScore = 80
                            },
                            Grade.build(inSession: session) {
                                $0.gradingPeriodID = "3"
                                $0.currentGrade = "C"
                                $0.currentScore = 70
                            }
                        ]
                        gradingPeriods = [
                            GradingPeriod.build(inSession: session) { $0.id = "1" },
                            GradingPeriod.build(inSession: session) { $0.id = "2" },
                            GradingPeriod.build(inSession: session) { $0.id = "3" }
                        ]
                    }

                    it("should be the current grade without specifying grading period item") {
                        course.currentGradingPeriodID = "2"
                        expect(course.totalGrade(nil)) == "B  80%"
                    }

                    it("should be the grade for the grading period item") {
                        expect(course.totalGrade(GradingPeriodItem.some(gradingPeriods[0]))) == "A  100%"
                        expect(course.totalGrade(GradingPeriodItem.some(gradingPeriods[1]))) == "B  80%"
                    }

                    context("all") {
                        beforeEach {
                            let _ = Grade.build(inSession: session) {
                                $0.gradingPeriodID = nil
                                $0.currentGrade = "D"
                                $0.currentScore = 65
                                $0.course = course
                            }
                        }

                        it("should be the grade with a nil grading period id") {
                            course.totalForAllGradingPeriodsEnabled = true
                            expect(course.totalGrade(GradingPeriodItem.all)) == "D  65%"
                        }

                        it("should be empty without total for all grading periods enabled") {
                            course.totalForAllGradingPeriodsEnabled = false
                            expect(course.totalGrade(GradingPeriodItem.all)) == "-"
                        }
                    }
                }
            }
        }
    }
}
