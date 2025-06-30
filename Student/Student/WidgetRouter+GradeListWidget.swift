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

import Core
import UIKit

extension WidgetRouter {

    static func createGradeListRouter() -> WidgetRouter {
        WidgetRouter(originValue: "grade-list-widget", handlers: [
            gradeListTabHandler
        ])
    }

    // MARK: - Handlers

    private static var gradeListTabHandler: RouteHandler {
        .init("/courses/:courseId/grades", action: { url, params, view in
            Analytics.shared.logEvent(GradeListWidgetEventNames.openGrades.rawValue)

            guard let courseId = params["courseId"] else { return }

            // Switch to Dashboard tab
            view.selectTab(at: 0)
            view.resetNavigationToRoot()

            // Show course view
            var courseURL = url
            courseURL.path = "/courses/\(courseId)"

            guard
                let rootVC = view.tabController.selectedViewController,
                let courseVC = view.env.router.match(courseURL) as? VisibilityObservingViewController
            else { return }

            view.env.router.show(courseVC, from: rootVC)

            // Show Grades tab
            courseVC.onAppearOnce {
                view.env.router.route(
                    to: url,
                    from: courseVC
                )
            }
        })
    }
}
