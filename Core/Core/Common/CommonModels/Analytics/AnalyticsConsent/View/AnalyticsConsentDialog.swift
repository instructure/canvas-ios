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

import UIKit

extension UIAlertController {

    public static func showAnalyticsConsentDialog(
        env: AppEnvironment = .shared,
        consentAction: @escaping (Bool) -> Void
    ) {
        guard let viewController = env.topViewController else {
            consentAction(false)
            return
        }

        let alert = analyticsConsentDialog(consentAction: consentAction)
        viewController.present(alert, animated: true)
    }

    private static func analyticsConsentDialog(consentAction: @escaping (Bool) -> Void) -> UIAlertController {
        let intro = String(localized: "We collect anonymous application data to help our team identify technical issues and optimize app features.", bundle: .core)
        let bullet1 = String(localized: "• No Personal Profiles: We do not track your identity or show advertisements.", bundle: .core)
        let bullet2 = String(localized: "• No Data Selling: Your information is never sold to third parties.", bundle: .core)
        let bullet3 = String(localized: "• Full Control: You can adjust these settings at any time.", bundle: .core)
        let message = [intro, bullet1, bullet2, bullet3].joined(separator: "\n\n")

        let alert = UIAlertController(
            title: String(localized: "Help us build a better app", bundle: .core),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "Decline", bundle: .core), style: .cancel) { _ in
            consentAction(false)
        })
        alert.addAction(UIAlertAction(title: String(localized: "Allow", bundle: .core), style: .default) { _ in
            consentAction(true)
        })

        return alert
    }
}
