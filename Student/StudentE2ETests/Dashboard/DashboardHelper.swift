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

import Foundation
import TestsFoundation
import XCTest

public class DashboardHelper: BaseHelper {
    public static func courseCard(course: DSCourse) -> Element { app.find(id: "DashboardCourseCell.\(course.id)") }
    public static var dashboardSettings: Element { app.find(id: "Dashboard.settingsButton", type: .other) }
    public static var profileButton: Element { app.find(id: "Dashboard.profileButton") }
    public static var dashboardSettingsShowGradeToggle: Element { app.find(id: "DashboardSettings.showGradesToggle", type: .switch) }
    public static var doneButton: Element { app.find(id: "screen.dismiss", type: .button) }

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
