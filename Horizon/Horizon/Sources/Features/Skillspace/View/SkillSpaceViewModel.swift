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
import WebKit

final class SkillSpaceViewModel: EmbeddedWebPageViewModel, EmbeddedWebPageNavigation {
    var urlPathComponent: String
    var queryItems: [URLQueryItem] = []
    var navigationBarTitle: String

    // MARK: - Dependencies

    private let baseURL: URL
    private let router: Router

    init(
        baseURL: URL,
        router: Router
    ) {
        self.baseURL = baseURL
        self.router = router
        urlPathComponent = "/skillspace"
        navigationBarTitle = String(localized: "Skillspace", bundle: .horizon)
    }

    func openURL(_ url: URL, viewController: WeakViewController) {
        if url.absoluteString.contains("learn/"), let courseID = url.pathComponents.last {
            navigateCourseDetails(courseID: courseID, viewController: viewController)
        } else {
            router.route(to: url, from: viewController)
        }
    }

    private func navigateCourseDetails(courseID: String, viewController: WeakViewController) {
        var courseURL = baseURL
        courseURL.appendPathComponent("courses")
        courseURL.appendPathComponent(courseID)
        router.route(to: courseURL, from: viewController)
    }
}
