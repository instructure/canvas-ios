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
    let courseColor: Color
    let imageUrl: URL?
    let grade: String?
    let a11yLabel: String

    let showGrades: Bool
    let showColorOverlay: Bool

    var isAvailableOffline: Bool {
        guard let selections = AppEnvironment.shared.userDefaults?.offlineSyncSelections else { return false }
        return selections.contains { $0.contains("courses/\(model.id)") }
    }

    // Including the whole model to ensure any change triggers a view update.
    var id: CoursesAndGroupsWidgetCourseItem { model }

    private let model: CoursesAndGroupsWidgetCourseItem
    private let router: Router

    init(
        model: CoursesAndGroupsWidgetCourseItem,
        showGrades: Bool,
        showColorOverlay: Bool,
        router: Router
    ) {
        self.model = model

        self.title = model.title
        self.courseColor = Color(hexString: model.colorString) ?? .textDark
        self.imageUrl = model.imageUrl
        self.grade = model.grade

        self.a11yLabel = {
            if let grade = model.grade, showGrades {
                [model.title, String(localized: "Grade", bundle: .core), grade]
                    .accessibilityJoined()
            } else {
                model.title
            }
        }()

        self.showGrades = showGrades
        self.showColorOverlay = showColorOverlay

        self.router = router
    }

    func didTapCard(from controller: WeakViewController) {
        let route: String
        if let colorWithoutHash = model.colorString?.dropFirst() {
            route = "/courses/\(model.id)?contextColor=\(colorWithoutHash)"
        } else {
            route = "/courses/\(model.id)"
        }

        router.route(to: route, from: controller)
    }

    func didTapManageOfflineContent(from controller: WeakViewController) {
        let route = "/offline/sync_picker/\(model.id)"

        router.route(to: route, from: controller, options: .modal(isDismissable: false, embedInNav: true))
    }

    func didTapCustomize(from controller: WeakViewController) {
        let viewModel = CustomizeCourseViewModel(
            courseId: model.id,
            courseImage: imageUrl,
            courseColor: courseColor.uiColor,
            courseName: title,
            hideColorOverlay: !showColorOverlay
        )

        router.show(
            CoreHostingController(CustomizeCourseView(viewModel: viewModel)),
            from: controller,
            options: .modal(.formSheet, isDismissable: false, embedInNav: true),
            analyticsRoute: "/dashboard/customize_course"
        )
    }

    static func == (lhs: CourseCardViewModel, rhs: CourseCardViewModel) -> Bool {
        lhs.model == rhs.model
    }
}
