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
import Core
import TestsFoundation
import XCTest

public class PeopleHelper: BaseHelper {
    public static func navigateToPeople(course: DSCourse) {
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.people.tap()
    }

    public static func navBar(course: DSCourse) -> Element {
        app.find(id: "People, \(course.name)")
    }

    public static var filterButton: Element {
        app.find(id: "All People").rawElement.find(label: "Filter", type: .button)
    }

    public static func peopleCell(index: Int) -> Element {
        app.find(id: "people-list-cell-row-\(index)")
    }

    public static func roleLabelOfPeopleCell(index: Int) -> Element {
        app.find(id: "people-list-cell-row-\(index).role-label")
    }

    public static func nameLabelOfPeopleCell(index: Int) -> Element {
        app.find(id: "people-list-cell-row-\(index).name-label")
    }

    enum ContextCard: String, ElementWrapper {
        case userNameLabel
        case courseLabel
        case sectionLabel
    }
}
