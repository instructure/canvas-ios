//
//  CourseAPISpec.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 7/25/16.
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

class CourseAPISpec: QuickSpec {
    override func spec() {
        describe("Courses API") {
            describe("GET /courses") {
                context("all the time") {
                    var courses: [JSONObject]!
                    beforeEach {
                        courses = self.fetchCourses(.All)
                    }

                    it("has all the json") {
                        let shape: JSONShape = [
                            "id",
                            "name",
                            "course_code",
                            "is_favorite",
                            "start_at",
                            "end_at",
                            "hide_final_grades",
                            "syllabus_body",
                            "default_view",
                            objects("enrollments", [
                                "type"
                            ])
                        ]
                        expect(courses).to(beShapedLike(shape))
                    }

                    describe("student enrollments") {
                        beforeEach {
                            self.attempt {
                                // removes courses that have enrollments that are not student enrollments
                                courses = try courses.filter {
                                    let enrollments: [JSONObject] = try $0 <| "enrollments"
                                    return try enrollments.filter { try $0 <| "type" != "student" }.isEmpty
                                }

                                expect(courses).toNot(beEmpty())
                            }
                        }

                        it("includes current grading period id") {
                            let shape: JSONShape = [
                                objects("enrollments", [
                                    "current_grading_period_id"
                                ])
                            ]
                            expect(courses).to(beShapedLike(shape))
                        }

                        it("includes grades and scores") {
                            let shape: JSONShape = [
                                objects("enrollments", [
                                    "computed_current_grade",
                                    "computed_current_score",
                                    "computed_final_grade",
                                    "computed_final_score",
                                ])
                            ]
                            expect(courses).to(beShapedLike(shape))
                        }
                    }
                }

                context("when there is a nickname") {
                    var courses: [JSONObject]!
                    beforeEach {
                        courses = self.fetchCourses(.Nickname)
                        expect(courses).toNot(beEmpty())
                    }

                    it("it has the original name") {
                        expect(courses).to(beShapedLike(["original_name"]))
                    }
                }

                context("when there are restricted courses") {
                    var courses: [JSONObject]!
                    beforeEach {
                        courses = self.fetchCourses(.AccessRestricted)
                    }

                    it("removes restricted courses") {
                        let shape: JSONShape = [!"access_restricted_by_date"]
                        expect(courses).to(beShapedLike(shape))
                    }
                }

                context("with mgp") {
                    var courses: [JSONObject]!
                    beforeEach {
                        courses = self.fetchCourses(.MGP)
                    }

                    describe("student enrollments") {
                        var studentEnrollment: JSONObject!
                        beforeEach {
                            studentEnrollment = self.getStudentEnrollment(from: courses)
                        }

                        it("includes current grading period grades") {
                            let shape: JSONShape = [
                                "current_period_computed_current_grade",
                                "current_period_computed_current_score",
                                "current_period_computed_final_grade",
                                "current_period_computed_final_score",
                            ]
                            expect(studentEnrollment).to(beShapedLike(shape))
                        }
                    }
                }
            }
        }
    }
}
