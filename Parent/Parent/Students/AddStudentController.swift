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

    @objc func addStudent() {
        guard let presenting = presentingViewController else { return }
        let picker = BottomSheetPickerViewController.create()
        picker.addAction(
            image: nil,
            title: NSLocalizedString("QR Code", comment: ""),
            accessibilityIdentifier: "DashboardViewController.addStudent.qrCode"
        ) { [weak self] in
            self?.scanQRCode()
        }
        picker.addAction(
            image: nil,
            title: NSLocalizedString("Pairing Code", comment: ""),
            accessibilityIdentifier: "DashboardViewController.addStudent.pairingCode"
        ) { [weak self] in
            self?.useInput()
        }
        env.router.show(picker, from: presenting, options: .modal(), analyticsRoute: "/profile/observees/new")
    }

    func useInput() {
        let title = NSLocalizedString("Add Student", comment: "")
        let message = NSLocalizedString("Input the student pairing code provided to you.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = NSLocalizedString("Pairing Code", comment: "")
        }
        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("Add", comment: ""), style: .default, handler: { [weak self] _ in
            guard let textField = alert.textFields?.first, let code = textField.text else { return }
            self?.pair(with: code)
        }))
        guard let vc = presentingViewController else { return }
        env.router.show(alert, from: vc, options: .modal(), analyticsRoute: "/profile/observees/new/manualcode")
    }

    func pair(with code: String) {
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

    func scanQRCode() {
        guard let presenting = presentingViewController else { return }
        let scanner = ScannerViewController()
        scanner.delegate = self
        self.env.router.show(scanner, from: presenting, options: .modal(.fullScreen), analyticsRoute: "/profile/observees/new/scanqr")
    }
}

extension AddStudentController: ScannerDelegate {
    func scanner(_ scanner: ScannerViewController, didScanCode code: String) {
        env.router.dismiss(scanner) {
            guard
                let components = URLComponents(string: code),
                let host = components.host,
                let pairingCode = components.queryItems?.first(where: { $0.name == "code" })?.value
            else {
                let error = NSError.instructureError(NSLocalizedString("Could not parse QR code, QR code invalid", comment: ""))
                (self.presentingViewController as? ErrorViewController)?.showError(error)
                return
            }

            guard host == self.env.currentSession?.baseURL.host else {
                let title = NSLocalizedString("Domain mismatch", comment: "")
                let msg = NSLocalizedString(
                    """
                    The student you are trying to add is at a different Canvas institution.
                    Sign in or create an account with that institution to add this student.
                    """,
                    comment: "")
                (self.presentingViewController as? ErrorViewController)?.showAlert(title: title, message: msg)
                return
            }
            self.pair(with: pairingCode)
        }
    }
}
