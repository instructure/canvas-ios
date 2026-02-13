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

@Observable
final class GroupCardViewModel: Identifiable, Equatable {

    let title: String
    let courseName: String
    let color: Color

    // Including the whole model to ensure any change triggers a view update.
    var id: CoursesAndGroupsWidgetGroupItem { model }

    private let model: CoursesAndGroupsWidgetGroupItem
    private let onCardTap: (WeakViewController) -> Void

    init(
        model: CoursesAndGroupsWidgetGroupItem,
        onCardTap: @escaping (WeakViewController) -> Void
    ) {
        self.model = model

        self.title = model.title
        self.courseName = model.courseName
        self.color = Color(hexString: model.color) ?? .textDark

        self.onCardTap = onCardTap
    }

    func didTapCard(from controller: WeakViewController) {
        onCardTap(controller)
    }

    static func == (lhs: GroupCardViewModel, rhs: GroupCardViewModel) -> Bool {
        lhs.model == rhs.model
    }
}
