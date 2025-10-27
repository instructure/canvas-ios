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

@testable import Core
@testable import Horizon

enum CompletedWidgetModelStub {
    static var listCompletedWidgetModels: [CompletedWidgetModel] {
        [
            .init(courseID: "ID-1", courseName: "Biology Basics", moduleCountCompleted: 5),
            .init(courseID: "ID-2", courseName: "Chemistry 101", moduleCountCompleted: 3),
            .init(courseID: "103", courseName: "Nursing Fundamentals", moduleCountCompleted: 8)
        ]
    }
}
