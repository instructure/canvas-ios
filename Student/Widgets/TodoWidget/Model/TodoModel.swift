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
import Core

class TodoModel: WidgetModel {
    override class var publicPreview: TodoModel {
        Self.make()
    }

    let items: [Plannable]

    init(isLoggedIn: Bool = true, items: [Plannable] = []) {
        self.items = items
        super.init(isLoggedIn: isLoggedIn)
    }
}

#if DEBUG
extension TodoModel {
    public static func make() -> TodoModel {
        let apiPlannables: [APIPlannable] = [
            .make(plannable_id: "1", plannable_type: "assignment", plannable: .init(details: "Details", title: "Important Assignment")),
            .make(plannable_id: "2", plannable_type: "discussion", plannable: .init(details: "Details", title: "Discussion About Everything")),
            .make(plannable_id: "3", plannable_type: "calendar_event", plannable: .init(details: "Details", title: "Huge Event")),
            .make(plannable_id: "4", plannable_type: "planner_note", plannable: .init(details: "Details", title: "Don't forget")),
            .make(plannable_id: "5", plannable_type: "quiz", plannable: .init(details: "Details", title: "Quiz About Life"))
        ]
        let items = apiPlannables.map {
            Plannable.save($0, userID: "", in: PreviewEnvironment().database.viewContext)
        }
        return TodoModel(items: items)
    }
}
#endif
