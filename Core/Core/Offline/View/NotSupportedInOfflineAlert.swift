//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

    /// To be used with target:action pattern.
    @objc
    public static func showItemNotAvailableInOfflineAlert(sender: Any?) {
        showItemNotAvailableInOfflineAlert()
    }

    public static func showItemNotAvailableInOfflineAlert(_ completion: (() -> Void)? = nil) {
        let title = NSLocalizedString("Offline mode", comment: "")
        let message = NSLocalizedString("This item is not available offline.", comment: "")
        let actionTitle = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            completion?()
        }
        alert.addAction(action)

        if let top = AppEnvironment.shared.topViewController {
            AppEnvironment.shared.router.show(alert, from: top, options: .modal())
        }
    }
}
