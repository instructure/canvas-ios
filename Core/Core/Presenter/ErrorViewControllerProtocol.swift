//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public protocol AlertViewController: class {
    var navigationController: UINavigationController? { get }
    func showAlert(title: String?, message: String?)
}

extension AlertViewController {
    public func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

public protocol ErrorViewController: AlertViewController {
    func showError(_ error: Error)
    func showError(message: String)
}

extension ErrorViewController {
    public func showError(_ error: Error) {
        DispatchQueue.main.async {
            self.showError(message: error.localizedDescription)
        }
    }

    public func showError(message: String) {
        showAlert(title: nil, message: message)
    }
}
