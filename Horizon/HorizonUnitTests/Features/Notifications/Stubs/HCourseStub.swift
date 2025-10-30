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

@testable import Horizon

enum HCourseStub {
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
            overviewDescription: ""
        )
    }

    static var courses: [HCourse] {
        [
            HCourseStub.course,
            HCourse(
                id: "2",
                name: "Introduction to Computer Science",
                institutionName: "Tech University",
                state: "Active",
                enrollmentID: "123",
                enrollments: [],
                modules: [],
                progress: 0.2,
                overviewDescription: "Learn the fundamentals of programming and computer science."
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
                overviewDescription: "Explore key historical events from the 18th century to the present."
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
                overviewDescription: "An introduction to essential business and management principles."
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
                overviewDescription: "A foundation course in art, design, and creative expression."
            )
        ]
    }
}
