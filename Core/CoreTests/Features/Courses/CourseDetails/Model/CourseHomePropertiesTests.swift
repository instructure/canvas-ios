//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import XCTest
@testable import Core

class CourseHomePropertiesTests: XCTestCase {

    func testHomeSubLabel() {
        XCTAssertEqual(CourseDefaultView.assignments.homeSubLabel, String(localized: "Assignments", bundle: .core))
        XCTAssertEqual(CourseDefaultView.feed.homeSubLabel, String(localized: "Recent Activity", bundle: .core))
        XCTAssertEqual(CourseDefaultView.modules.homeSubLabel, String(localized: "Course Modules", bundle: .core))
        XCTAssertEqual(CourseDefaultView.syllabus.homeSubLabel, String(localized: "Syllabus", bundle: .core))
        XCTAssertEqual(CourseDefaultView.wiki.homeSubLabel, String(localized: "Front Page", bundle: .core))
    }

    func testHomeRoute() {
        XCTAssertEqual(CourseDefaultView.assignments.homeRoute(courseID: "123"), URL(string: "/courses/123/assignments"))
        XCTAssertEqual(CourseDefaultView.feed.homeRoute(courseID: "123"), URL(string: "/courses/123/activity_stream"))
        XCTAssertEqual(CourseDefaultView.modules.homeRoute(courseID: "123"), URL(string: "/courses/123/modules"))
        XCTAssertEqual(CourseDefaultView.syllabus.homeRoute(courseID: "123"), URL(string: "/courses/123/syllabus"))
        XCTAssertEqual(CourseDefaultView.wiki.homeRoute(courseID: "123"), URL(string: "/courses/123/pages/front_page"))
    }
}
