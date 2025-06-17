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
    override class var publicPreview: CourseTotalGradeModel {
        CourseTotalGradeModel(
            data: CourseTotalGradeData(
                courseID: "random-course-id",
                courseName: "Example Course",
                courseColor: .mint,
                grade: .init("89%")
            )
        )
    }

    var data: CourseTotalGradeData?

    init(isLoggedIn: Bool = true, data: CourseTotalGradeData? = nil) {
        self.data = data
        super.init(isLoggedIn: isLoggedIn)
    }
}

struct CourseTotalGradeData {
    static func empty(courseID: String) -> CourseTotalGradeData{
        CourseTotalGradeData(
            courseID: courseID,
            courseName: "???",
            courseColor: nil,
            grade: GradeValue("", locked: true)
        )
    }

    struct GradeValue {
        let rawValue: String
        let locked: Bool

        init(_ rawValue: String, locked: Bool = false) {
            self.rawValue = rawValue
            self.locked = locked
        }
    }

    let courseID: String
    let courseName: String
    let courseColor: Color?
    let grade: GradeValue?
}
