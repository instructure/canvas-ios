//
//  SpecHelper.swift
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

extension CourseSpec {
    var validCourseJSON: JSONObject {
        return [
            "id": 1,
            "name": "Course 1",
            "course_code": "xyz",
            "is_favorite": true,
            "hide_final_grades": false,
            "default_view": "feed",
            "enrollments": [
                [
                    "type": "student",
                    "computed_current_grade": "A",
                    "computed_current_score": 100,
                    "computed_final_grade": "B",
                    "computed_final_score": 80,
                ],
                ["type": "teacher"],
                ["type": "observer"],
                ["type": "ta"],
                ["type": "designer"],
            ],
        ]
    }

    var mgpCourseJSON: JSONObject {
        var json = validCourseJSON
        json["enrollments"] = [
            [
                "type": "student",
                "current_grading_period_id": 1,
                "multiple_grading_periods_enabled": true,
                "current_period_computed_current_grade": "F",
                "current_period_computed_current_score": 50,
                "current_period_computed_final_grade": "D",
                "current_period_computed_final_score": 60,
                "totals_for_all_grading_periods_option": true,
            ]
        ]
        return json
    }
}

extension CourseAPISpec {
    enum CoursesFilter {
        case All, AccessRestricted, MGP, Nickname
    }

    func fetchCourses(filter: CoursesFilter) -> [JSONObject] {
        let session = User(credentials: .user1).session
        let stub = Stub(session: session, name: "CourseGetAllCourses", testCase: self, bundle: NSBundle(forClass: CourseSpec.self))
        let courses = fetchCourses(stub)

        let filterID: String
        switch filter {
        case .All:
            return courses
        case .AccessRestricted:
            filterID = "1801897"
        case .Nickname, .MGP:
            filterID = "1867097"
        }

        return (try? courses.filter { try $0.stringID("id") == filterID }) ?? []
    }

    func getStudentEnrollment(from courses: [JSONObject]) -> JSONObject {
        var studentEnrollment: JSONObject = [:]
        for course in courses {
            let enrollments: [JSONObject]? = try? ((try? course <| "enrollments") ?? []).filter { try $0 <| "type" == "student" }
            if let enrollment = enrollments?.first {
                studentEnrollment = enrollment
                break
            }
        }
        expect(studentEnrollment).toNot(beEmpty())
        return studentEnrollment
    }

    private func fetchCourses(stub: Stub) -> [JSONObject] {
        var courses: [JSONObject]!
        attempt {
            try Course.getAllCourses(stub.session).startWithStub(stub) { courses = $0 }
        }

        expect(courses).toNot(beNil())
        courses = courses ?? []
        return courses
    }
}
