//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore
import Core

class SettingsViewController: UIViewController {
    var env = AppEnvironment.shared

    // ---------------------------------------------
    // MARK: - IBOutlets
    // ---------------------------------------------
    @objc var logoutButton: UIBarButtonItem?
    @objc var closeButton: UIBarButtonItem?
    @objc var addButton: UIBarButtonItem?
    @IBOutlet weak var observeesContainerView: UIView!
    @objc var session: Session?

    @objc let reuseIdentifier = "SettingsObserveesCell"

    // ---------------------------------------------
    // MARK: - ViewModel
    // ---------------------------------------------
    var viewModel: SettingsViewModel!
    var observeesViewController: StudentsListViewController?

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    static func create(env: AppEnvironment = .shared, session: Session) -> SettingsViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.session = session
        controller.viewModel = SettingsViewModel(session: session)
        //  swiftlint:disable:next force_try
        controller.observeesViewController = try! StudentsListViewController(session: session)
        controller.observeesViewController?.selectStudentAction = { [weak controller] session, student in
            guard let view = controller else { return }
            env.router.route(to: .observeeThresholds(student.id), from: view, options: nil)
        }
        return controller
    }

    // ---------------------------------------------
    // MARK: - LifeCycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        setupObserveeList()

        self.title = NSLocalizedString("Manage Children", comment: "Title of the manage children screen. This screen is used to add/remove children that a parent is observing.")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    @objc func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.useContextColor(ColorScheme.observer.color)

        let addStudentButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAddStudent))
        navigationItem.rightBarButtonItem = addStudentButton
    }

    @objc func setupObserveeList() {
        guard let observeesViewController = observeesViewController else {
            return
        }

        observeesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        observeesViewController.willMove(toParent: self)
        addChild(observeesViewController)
        observeesContainerView.addSubview(observeesViewController.view)
        observeesViewController.didMove(toParent: self)
        observeesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|",
                                                                             options: .directionLeadingToTrailing,
                                                                             metrics: nil,
                                                                             views: ["subview": observeesViewController.view as Any]))
        observeesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|",
                                                                             options: .directionLeadingToTrailing,
                                                                             metrics: nil,
                                                                             views: ["subview": observeesViewController.view as Any]))
    }

    // ---------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @objc func actionAddStudent() {
        let title = NSLocalizedString("Add Student", comment: "")
        let message = NSLocalizedString("Input the student pairing code provided to you.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = NSLocalizedString("Pairing Code", comment: "")
        }

        alert.addAction(AlertAction(NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in }))
        env.router.show(alert, from: self, options: [.modal])

        alert.addAction(AlertAction(NSLocalizedString("Add", comment: ""), style: .default, handler: { [weak self] _ in
            guard let textField = alert.textFields?.first, let code = textField.text else { return }
            self?.addPairingCode(code: code)
        }))
    }

    private func addPairingCode(code: String) {
        let request = PostObserveesRequest(userID: "self", pairingCode: code)
        env.api.makeRequest(request) { [weak self] _, _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in }))
                    self.env.router.show(alert, from: self, options: [.modal])
                } else {
                    self.observeesViewController?.refresh()
                }
            }
        }
    }
}
