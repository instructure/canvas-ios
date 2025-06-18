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

import WidgetKit
import SwiftUI

class CourseTotalGradeModel: WidgetModel {

    struct CourseAttributes {
        let name: String
        let color: Color?
    }

    enum FetchResult {
        case grade(attributes: CourseAttributes, text: String)
        case noGrade(attributes: CourseAttributes)
        case restricted(attributes: CourseAttributes)
        case failure(attributes: CourseAttributes, error: String)
        case courseNotFound
    }

    struct Data {
        static func courseNotFound(courseID: String) -> Data {
            Data(
                courseID: courseID,
                fetchResult: .courseNotFound
            )
        }

        let courseID: String
        let fetchResult: FetchResult
    }

    override class var publicPreview: CourseTotalGradeModel {
        CourseTotalGradeModel(
            data: Data(
                courseID: "random-course-id",
                fetchResult: .grade(
                    attributes: CourseAttributes(
                        name: "Example Course",
                        color: .green
                    ),
                    text: "90%"
                )
            )
        )
    }

    var data: Data?

    init(isLoggedIn: Bool = true, data: Data? = nil) {
        self.data = data
        super.init(isLoggedIn: isLoggedIn)
    }
}

typealias CourseTotalGradeData = CourseTotalGradeModel.Data
