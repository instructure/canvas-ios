//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation
import SwiftUI

struct GroupCardViewModel: Identifiable, Equatable {

    let id: String
    let title: String
    let courseName: String
    let courseColor: Color
    let groupColor: Color
    let memberCount: String

    private let model: CoursesAndGroupsWidgetGroupItem
    private let router: Router

    init(
        model: CoursesAndGroupsWidgetGroupItem,
        router: Router
    ) {
        self.model = model

        self.id = model.id
        self.title = model.title
        self.courseName = model.courseName
        self.courseColor = Color(hexString: model.courseColorString) ?? .textDark
        self.groupColor = Color(hexString: model.groupColorString) ?? .textDark
        self.memberCount = String(model.memberCount)

        self.router = router
    }

    func didTapCard(from controller: WeakViewController) {
        let route = "/groups/\(id)"

        router.route(to: route, from: controller, options: .push)
    }

    static func == (lhs: GroupCardViewModel, rhs: GroupCardViewModel) -> Bool {
        lhs.model == rhs.model
    }
}
