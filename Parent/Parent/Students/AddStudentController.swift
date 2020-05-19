//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Core

class AddStudentController {
    typealias Handler = (Error?) -> Void
    var env = AppEnvironment.shared
    weak var presentingViewController: UIViewController?
    var handler: Handler

    init(presentingViewController: UIViewController, handler: @escaping Handler) {
        self.presentingViewController = presentingViewController
        self.handler = handler
    }

    @objc func actionAddStudent() {
        let title = NSLocalizedString("Add Student", comment: "")
        let message = NSLocalizedString("Input the student pairing code provided to you.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = NSLocalizedString("Pairing Code", comment: "")
        }
        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("Add", comment: ""), style: .default, handler: { [weak self] _ in
            guard let textField = alert.textFields?.first, let code = textField.text else { return }
            self?.addPairingCode(code: code)
        }))
        guard let vc = presentingViewController else { return }
        env.router.show(alert, from: vc, options: .modal())
    }

    func addPairingCode(code: String) {
        let request = PostObserveesRequest(userID: "self", pairingCode: code)
        env.api.makeRequest(request) { [weak self] _, _, error in
            guard let self = self, let vc = self.presentingViewController else { return }
            performUIUpdate {
                if let error = error {
                    let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in }))
                    self.env.router.show(alert, from: vc, options: .modal())
                }
                self.handler(error)
            }
        }
    }
}
