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
import Observation
import SafariServices

@Observable
final class ExternalURLViewModel {

    // MARK: - Outputs

    let title: String

    // MARK: - Dependencies

    private let router: Router
    private let url: URL
    private let viewController: WeakViewController?

    // MARK: - Init

    init(
        title: String,
        url: URL,
        viewController: WeakViewController? = nil,
        router: Router = AppEnvironment.shared.router
    ) {
        self.url = url
        self.title = title
        self.viewController = viewController
        self.router = router

        openURLAfterDelay()
    }

    // MARK: - Actions

    func openURL() {
        guard let viewController = viewController?.value, UIApplication.shared.canOpenURL(url) else { return }
        router.show(
            SFSafariViewController(url: url),
            from: viewController,
            options: .modal(.overFullScreen)
        )
    }

    private func openURLAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.openURL()
        }
    }
}
