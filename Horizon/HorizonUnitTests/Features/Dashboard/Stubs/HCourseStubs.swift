//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

@testable import Core
import Foundation
@testable import Horizon

enum HCourseStubs {
    static var activeCourses: [HCourse] {
        [
            HCourse(
                id: "course-1",
                name: "iOS Development 101",
                institutionName: "Tech University",
                state: HCourse.EnrollmentState.active.rawValue,
                enrollmentID: "enrollment-1",
                enrollments: [],
                modules: [],
                progress: 0.75,
                overviewDescription: "Learn the basics of iOS development",
                imageUrl: "https://example.com/course1.jpg",
                currentLearningObject: .init(
                    moduleTitle: "Module 1",
                    learningObjectName: "Introduction to Swift",
                    learningObjectID: "item-1",
                    type: .assignment,
                    dueDate: "2025/12/31",
                    url: URL(string: "https://example.com/module/1"),
                    estimatedTime: "30 mins",
                    isNewQuiz: false
                ),
                programs: []
            ),
            HCourse(
                id: "course-2",
                name: "Advanced SwiftUI",
                institutionName: "Tech University",
                state: HCourse.EnrollmentState.active.rawValue,
                enrollmentID: "enrollment-2",
                enrollments: [],
                modules: [],
                progress: 0.45,
                overviewDescription: "Master SwiftUI development",
                imageUrl: "https://example.com/course2.jpg",
                currentLearningObject: .init(
                    moduleTitle: "Module 2",
                    learningObjectName: "State Management",
                    learningObjectID: "item-2",
                    type: .page,
                    dueDate: "2025/11/15",
                    url: URL(string: "https://example.com/module/2"),
                    estimatedTime: "45 mins",
                    isNewQuiz: false
                ),
                programs: []
            ),
            HCourse(
                id: "course-3",
                name: "Testing in iOS",
                institutionName: "Tech University",
                state: HCourse.EnrollmentState.active.rawValue,
                enrollmentID: "enrollment-3",
                enrollments: [],
                modules: [],
                progress: 0.0,
                overviewDescription: "Learn testing strategies",
                imageUrl: nil,
                currentLearningObject: nil,
                programs: []
            )
        ]
    }

    static var invitedCourses: [HCourse] {
        [
            HCourse(
                id: "course-4",
                name: "Invited Course",
                institutionName: "Tech University",
                state: HCourse.EnrollmentState.invited.rawValue,
                enrollmentID: "enrollment-4",
                enrollments: [],
                modules: [],
                progress: 0.0,
                overviewDescription: "A course you've been invited to",
                imageUrl: nil,
                currentLearningObject: nil,
                programs: []
            )
        ]
    }

    static var coursesWithPrograms: [HCourse] {
        let program1 = Program(
            id: "program-1",
            name: "iOS Developer Track",
            variant: "Full-Time",
            description: "Complete iOS development program",
            date: "2025-09-01",
            courseCompletionCount: 1,
            courses: [
                ProgramCourse(
                    id: "course-1",
                    isSelfEnrolled: true,
                    isRequired: true,
                    status: "ENROLLED",
                    progressID: "progress-1",
                    completionPercent: 75.0
                )
            ]
        )

        var course1 = activeCourses[0]
        course1.programs = [program1]

        return [course1]
    }

    static var mixedStateCourses: [HCourse] {
        activeCourses + invitedCourses
    }

    static var course: HCourse {
        HCourse(
            id: "1",
            name: "Course 1",
            institutionName: "Career 1",
            state: "Active",
            enrollmentID: "12",
            enrollments: [],
            modules: [],
            progress: 0.2,
            overviewDescription: "",
            currentLearningObject: nil
        )
    }

    static var courses: [HCourse] {
        [
            HCourseStubs.course,
            HCourse(
                id: "2",
                name: "Introduction to Computer Science",
                institutionName: "Tech University",
                state: "Active",
                enrollmentID: "123",
                enrollments: [],
                modules: [],
                progress: 0.2,
                overviewDescription: "Learn the fundamentals of programming and computer science.",
                currentLearningObject: nil
            ),
            HCourse(
                id: "3",
                name: "Modern World History",
                institutionName: "Career Academy",
                state: "Active",
                enrollmentID: "1233",
                enrollments: [],
                modules: [],
                progress: 0.85,
                overviewDescription: "Explore key historical events from the 18th century to the present.",
                currentLearningObject: nil
            ),
            HCourse(
                id: "4",
                name: "Business Management 101",
                institutionName: "Global Business School",
                state: "Completed",
                enrollmentID: "4567",
                enrollments: [],
                modules: [],
                progress: 1.0,
                overviewDescription: "An introduction to essential business and management principles.",
                currentLearningObject: nil
            ),
            HCourse(
                id: "5",
                name: "Art & Design Fundamentals",
                institutionName: "Creative Institute",
                state: "Invited",
                enrollmentID: "7890",
                enrollments: [],
                modules: [],
                progress: 0.0,
                overviewDescription: "A foundation course in art, design, and creative expression.",
                currentLearningObject: nil
            )
        ]
    }
}
