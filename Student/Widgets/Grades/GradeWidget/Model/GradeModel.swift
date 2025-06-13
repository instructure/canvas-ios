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
import Core

class GradeModel: WidgetModel {
    override class var publicPreview: GradeModel {
        Self.make()
    }

    let gradeItem: GradeItem
    let error: GradeError?

    init(
        isLoggedIn: Bool = true,
        gradeItem: GradeItem,
        error: GradeError? = nil
    ) {
        self.gradeItem = gradeItem
        self.error = error

        super.init(isLoggedIn: isLoggedIn)
    }
}

enum GradeError: Error {
    case fetchingDataFailure
}

// MARK: - Previews

extension GradeModel {

    static func make() -> GradeModel {
        let gradeItem = GradeItem.make(
            courseId: "1",
            courseName: "First Course",
            totalGrade: "A",
            color: .red
        )
        return GradeModel(gradeItem: gradeItem)
    }
}
