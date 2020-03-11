//
// Created by Andrew Cobb on 3/2/20.
// Copyright (c) 2020 Instructure. All rights reserved.
//

import Foundation
@testable import Core

public class MiniCanvasState: Encodable {
    public var courses: [MiniCourse]
    public var enrollments: [APIEnrollment] = []
    public var students: [APIUser]
    public var teachers: [APIUser]
    public var observers: [APIUser]
    public var selfId: String
    public var brandVariables = APIBrandVariables.make()
    public var unreadCount: UInt = 3
    public var accountNotifications: [APIAccountNotification]
    public var customColors: [String: String]
    public var favoriteCourses: Set<ID>
    public let idGenerator = IDGenerator()

    public class IDGenerator: Encodable {
        private var nextID: Int = 10

        public func next<I: ExpressibleByIntegerLiteral>() -> I where I.IntegerLiteralType == Int {
            defer { nextID += 1 }
            return I.init(integerLiteral: nextID)
        }
    }

    init(baseUrl: URL) {
        courses = [
            APICourse.make(id: idGenerator.next(), name: "Course One", course_code: "C1", workflow_state: .available, enrollments: []),
            APICourse.make(id: idGenerator.next(), name: "Course Two (unpublished)", course_code: "C2", workflow_state: .unpublished, enrollments: []),
            APICourse.make(id: idGenerator.next(), name: "Course Three (completed)", course_code: "C3", workflow_state: .completed, enrollments: []),
        ].map(MiniCourse.init)

        students = [
            APIUser.makeUser(role: "Student", id: idGenerator.next()),
            APIUser.makeUser(role: "Student", id: idGenerator.next()),
            APIUser.makeUser(role: "Student", id: idGenerator.next()),
        ]

        teachers = [APIUser.makeUser(role: "Teacher", id: idGenerator.next())]
        observers = [APIUser.makeUser(role: "Parent", id: idGenerator.next())]
        accountNotifications = [.make(id: idGenerator.next())]

        selfId = students[0].id
        favoriteCourses = Set(courses.map { $0.id })
        customColors = [:]

        for course in courses {
            func makeAssignment(name: String) -> MiniAssignment {
                let id: ID = idGenerator.next()
                return MiniAssignment(APIAssignment.make(id: id, course_id: course.id, name: name, html_url: URL(string: "\(baseUrl)/courses/\(course.id)/assignments/\(id)")!))
            }

            course.gradingPeriods = [
                .make(id: idGenerator.next(), title: "Grading Period 1"),
                .make(id: idGenerator.next(), title: "Grading Period 2"),
            ]
            course.assignmentGroups = [
                .make(id: idGenerator.next(), name: "group 0", position: 0),
                .make(id: idGenerator.next(), name: "group 1", position: 1),
            ]

            course.add(assignment: makeAssignment(name: "Assignment 1"), toGroupAtIndex: 0)
            course.add(assignment: makeAssignment(name: "Assignment 2"), toGroupAtIndex: 0)
            course.add(assignment: makeAssignment(name: "Assignment 3"), toGroupAtIndex: 1)

            course.assignments[0].submissions = students.map { student in
                APISubmission.make(
                    id: idGenerator.next(),
                    assignment_id: course.assignments[0].id,
                    user_id: student.id,
                    body: "A submission from \(student.name)"
                )
            }

            customColors["course_\(course.id)"] = Self.colorForID(id: course.id)
            for student in students {
                enroll(student, intoCourse: course, as: "StudentEnrollment")
            }
            enroll(teachers[0], intoCourse: course, as: "TeacherEnrollment")
            enroll(observers[0], intoCourse: course, as: "ObserverEnrollment", observing: students[0])
        }
    }
}

extension MiniCanvasState {
    public func enroll(_ user: APIUser, intoCourse course: MiniCourse, as role: String, observing: APIUser? = nil) {
        let enrollment = APIEnrollment.make(
            id: idGenerator.next(),
            course_id: course.id.value,
            type: role,
            user_id: user.id,
            associated_user_id: observing?.id,
            role: role,
            user: user,
            observed_user: observing
        )
        enrollments.append(enrollment)
        course.api.enrollments = course.api.enrollments ?? []
        course.api.enrollments?.append(enrollment)
    }

    public func course(byId id: String?) -> MiniCourse? {
        courses.first { $0.id.value == id }
    }
    public func assignment(byId id: String?) -> MiniAssignment? {
        courses.lazy.compactMap({ $0.assignment(byId: id) }).first
    }
    public func user(byId id: String) -> APIUser? {
        (students + teachers + observers).first { $0.id == id }
    }

    public var selfUser: APIUser { user(byId: selfId)! }

    public func userEnrollments(forId id: String? = nil) -> [APIEnrollment] {
        enrollments.filter { $0.user_id == id ?? selfId }
    }

    static func colorForID(id: ID) -> String {
        let phi: CGFloat = (1 + sqrt(5)) / 2
        // multiply by a very irrational value so that colors are distant
        let color = UIColor(hue: CGFloat(Int(id.value) ?? 0) * phi, saturation: 1, brightness: 0.75, alpha: 1)
        return color.hexString
    }
}
