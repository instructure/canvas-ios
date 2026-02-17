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
final class CourseCardViewModel: Identifiable, Equatable {

    let title: String
    let color: Color

    // Including the whole model to ensure any change triggers a view update.
    var id: CoursesAndGroupsWidgetCourseItem { model }

    private let model: CoursesAndGroupsWidgetCourseItem
    private let onCardTap: (WeakViewController) -> Void

    init(
        model: CoursesAndGroupsWidgetCourseItem,
        onCardTap: @escaping (WeakViewController) -> Void
    ) {
        self.model = model

        self.title = model.title
        self.color = Color(hexString: model.colorString) ?? .textDark

        self.onCardTap = onCardTap
    }

    func didTapCard(from controller: WeakViewController) {
        onCardTap(controller)
    }

    static func == (lhs: CourseCardViewModel, rhs: CourseCardViewModel) -> Bool {
        lhs.model == rhs.model
    }
}
