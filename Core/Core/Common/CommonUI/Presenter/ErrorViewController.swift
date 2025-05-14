//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public protocol ErrorViewController: AnyObject {
    func showAlert(title: String?, message: String?)
    func showError(_ error: Error)
    func showError(message: String)
}

extension ErrorViewController where Self: UIViewController {
    public func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", bundle: .core), style: .default))
        AppEnvironment.shared.router.show(alert, from: self, options: .modal())
    }
}

extension ErrorViewController {
    public func showError(_ error: Error) {
        showError(message: error.localizedDescription)
    }

    public func showError(message: String) {
        performUIUpdate {
            self.showAlert(title: nil, message: message)
        }
    }
}
