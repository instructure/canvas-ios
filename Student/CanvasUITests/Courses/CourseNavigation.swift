//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation

enum CourseNavigation {
    static var announcements: Element {
        return app.find(id: "courses-details.announcements-cell")
    }

    static var assignments: Element {
        return app.find(id: "courses-details.assignments-cell")
    }

    static var discussions: Element {
        return app.find(id: "courses-details.discussions-cell")
    }

    static var files: Element {
        return app.find(id: "courses-details.files-cell")
    }

    static var grades: Element {
        return app.find(id: "courses-details.grades-cell")
    }

    static var modules: Element {
        return app.find(id: "courses-details.modules-cell")
    }

    static var pages: Element {
        return app.find(id: "courses-details.pages-cell")
    }

    static var people: Element {
        return app.find(id: "courses-details.people-cell")
    }

    static var quizzes: Element {
        return app.find(id: "courses-details.quizzes-cell")
    }
}
