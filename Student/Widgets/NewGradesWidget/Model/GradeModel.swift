//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct GradeModel: TimelineEntry {
    let date = Date(timeIntervalSince1970: 0)
    let items: [GradeItem]

    init(items: [GradeItem]) {
        self.items = items
    }
}

#if DEBUG
extension GradeModel {
    public static func make() -> GradeModel {
        GradeModel(items: [
            GradeItem(assignmentName: "Essay #1: The Rocky Planets", grade: "95.75 / 100"),
            GradeItem(assignmentName: "Earth: The Pale Blue Dot on two lines", grade: "20 / 25"),
            GradeItem(assignmentName: "Introduction to the Solar System", grade: "A-"),
            GradeItem(assignmentName: "Biology 101", grade: "C+"),
        ])
    }
}
#endif
