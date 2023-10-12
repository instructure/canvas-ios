//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class DashboardHelper: BaseHelper {
    public static var dashboardSettings: XCUIElement { app.find(id: "Dashboard.settingsButton", type: .other) }
    public static var optionsButton: XCUIElement { app.find(label: "Dashboard Options", type: .button) }
    public static var dashboardSettingsButton: XCUIElement { app.find(label: "Dashboard Settings", type: .button) }
    public static var profileButton: XCUIElement { app.find(id: "Dashboard.profileButton", type: .button) }
    public static var editButton: XCUIElement { app.find(id: "Dashboard.editButton") }
    public static var doneButton: XCUIElement { app.find(id: "screen.dismiss", type: .button) }
    public static var coursesLabel: XCUIElement { app.find(id: "dashboard.courses.heading-lbl") }
    public static var offlineLine: XCUIElement { app.find(id: "offlineLine") }
    public static var dashboardSettingsShowGradeToggle: XCUIElement {
        return app.find(id: "DashboardSettings.showGradesToggle", type: .switch).find(type: .switch)
    }

    public static func courseCard(course: DSCourse? = nil, courseId: String? = nil) -> XCUIElement {
        return app.find(id: "DashboardCourseCell.\(course?.id ?? courseId!)")
    }

    public static func courseCardGradeLabel(course: DSCourse) -> XCUIElement {
        return app.find(id: "DashboardCourseCell.\(course.id).gradePill")
    }

    public static func courseOptionsButton(course: DSCourse) -> XCUIElement {
        return app.find(id: "DashboardCourseCell.\(course.id).optionsButton")
    }

    public static func toggleFavorite(course: DSCourse) {
        app.find(id: "DashboardCourseCell.\(course.id).favoriteButton", type: .button).hit()
    }

    public static func turnOnShowGrades() {
        optionsButton.hit()
        dashboardSettingsButton.hit()
        dashboardSettingsShowGradeToggle.forceTap()
        doneButton.hit()
    }

    public struct CourseInvitations {
        public static func acted(enrollment: DSEnrollment) -> XCUIElement {
            return app.find(id: "CourseInvitation.\(enrollment.id).acted")
        }

        public static func acceptButton(enrollment: DSEnrollment) -> XCUIElement {
            return app.find(id: "CourseInvitation.\(enrollment.id).acceptButton")
        }

        public static func rejectButton(enrollment: DSEnrollment) -> XCUIElement {
            return app.find(id: "CourseInvitation.\(enrollment.id).rejectButton")
        }
    }

    public struct Options {
        public static var manageOfflineContentButton: XCUIElement { app.find(label: "Manage Offline Content", type: .button) }
        public static var customizeCourseButton: XCUIElement { app.find(label: "Customize Course", type: .button) }

        public struct OfflineContent {
            public static var headerLabel: XCUIElement { app.find(label: "Offline Content", type: .staticText) }
            public static var storageInfoLabel: XCUIElement { app.find(labelContaining: "Storage Info", type: .other) }
            public static var syncButton: XCUIElement { app.find(label: "Sync", type: .button) }

            // Alert
            public static var alertSyncButton: XCUIElement { app.find(type: .alert).find(label: "Sync", type: .button) }
            public static var alertCancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }
            public static var alertSyncOfflineContentLabel: XCUIElement { app.find(label: "Sync Offline Content?", type: .staticText) }

            // Syncing offline content
            public static var syncingOfflineContentLabel: XCUIElement { app.find(label: "Syncing Offline Content") }

            // Course content selection
            public static var discussionsButton: XCUIElement { app.find(labelContaining: "Discussions", type: .button) }
            public static var gradesButton: XCUIElement { app.find(labelContaining: "Grades", type: .button) }
            public static var peopleButton: XCUIElement { app.find(labelContaining: "People", type: .button) }
            public static var syllabusButton: XCUIElement { app.find(labelContaining: "Syllabus", type: .button) }
            public static var bigBlueButtonButton: XCUIElement { app.find(labelContaining: "BigBlueButton", type: .button) }

            // Functions
            public static func courseButton(course: DSCourse) -> XCUIElement {
                return app.find(type: .scrollView).find(labelContaining: "\(course.name)", type: .button)
            }

            public static func unselectedTickerOfCourseButton(course: DSCourse) -> XCUIElement {
                return courseButton(course: course).waitUntil(.visible).find(label: "emptyLine")
            }

            public static func selectedTickerOfCourseButton(course: DSCourse) -> XCUIElement {
                return courseButton(course: course).waitUntil(.visible).find(label: "completeSolid")
            }

            public static func partiallySelectedTickerOfCourseButton(course: DSCourse) -> XCUIElement {
                return courseButton(course: course).waitUntil(.visible).find(label: "partialSolid")
            }

            public static func courseLabel(course: DSCourse) -> XCUIElement {
                return app.find(type: .scrollView).find(label: course.name, type: .staticText)
            }
        }
    }

    @discardableResult
    public static func createFrontPageForCourse(course: DSCourse) -> DSPage {
        let pageBody = CreateDSPageRequest.RequestedDSPage(title: "Dashboard Test Page", body: "Dashboard Test Page Body", front_page: true, published: true)
        return seeder.createPage(courseId: course.id, requestBody: pageBody)
    }

    public static func createCourses(number: Int) -> [DSCourse] {
        var courses = [DSCourse]()
        for i in 0..<number {
            let courseName = "Course \(i + 1) DataSeed iOS \(Int(Date().timeIntervalSince1970))"
            courses.append(seeder.createCourse(name: courseName))
        }
        return courses
    }
}

public class DashboardHelperParent: BaseHelper {
    public static func courseCard(course: DSCourse? = nil, courseId: String? = nil) -> XCUIElement {
        return app.find(id: "course_cell_\(course?.id ?? courseId!)")
    }
}
