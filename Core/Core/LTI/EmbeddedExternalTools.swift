//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import SafariServices

/**
 This helper opens LTI launch urls that are not Canvas LTI launch urls in Safari.
 */
enum EmbeddedExternalTools {
    private static let externalToolChecks: [(URL) -> Bool] = [
        {
            $0.host?.contains("sharepoint.com") == true &&
            $0.path.contains("embed")
        }
    ]

    /**
     - returns: `True` if the LTI launch was handled by this method.
     */
    static func handle(
        url: URL,
        view: UIViewController,
        loginDelegate: LoginDelegate?,
        router: Router
    ) -> Bool {
        // If there's one check that passes for the url then we're safe to handle it
        guard
            externalToolChecks.contains(where: { check in check(url) })
        else {
            return false
        }

        let openInSystemSafari = UserDefaults.standard.bool(forKey: "open_lti_safari")

        if openInSystemSafari {
            loginDelegate?.openExternalURLinSafari(url)
        } else {
            let safariModal = SFSafariViewController(url: url)
            router.show(safariModal, from: view, options: .modal(.overFullScreen))
        }

        return true
    }
}
