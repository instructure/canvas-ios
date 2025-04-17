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
import Foundation

struct NotAvailableYetFeatureViewModel {
    // MARK: - Outlets
    var description: String {
        String(localized: "This feature isn't available on iOS yet. To access \(feature.description), please log in using a web browser.", bundle: .horizon)
    }

    // MARK: - Properties

    let feature: NotAvailableYetFeature
    let router: Router
    let baseURL: URL?

    // MARK: - Inputs

    func openCanvasForCareerSkillspaceOnWeb(viewController: WeakViewController) {
        guard let baseURL = baseURL?.replaceHostWithCanvasForCareer(),
              let url = URL(string: "\(baseURL)/\(feature.path)?embedded=true") else {
            return
        }
        router.route(to: url, from: viewController)
    }
}

private extension URL {
    func replaceHostWithCanvasForCareer() -> URL? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        var newComponents = components
        newComponents.host?.replace("instructure.com", with: "canvasforcareer.com")
        return newComponents.url
    }
}
