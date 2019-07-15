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

typealias SettingsSessionAction = (_ session: Session)->Void
typealias SettingsObserveeSelectedAction = (_ session: Session, _ observee: Student)->Void

class SettingsViewController: UIViewController {
    
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
    // MARK: - External Closures
    // ---------------------------------------------
    @objc var closeAction: SettingsSessionAction? = nil
    @objc var allObserveesAction: SettingsSessionAction? = nil
    @objc var observeeSelectedAction: SettingsObserveeSelectedAction? = nil
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "SettingsViewController"
    @objc static func new(_ storyboardName: String = defaultStoryboardName, session: Session) -> SettingsViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: Bundle(for: self)).instantiateInitialViewController() as? SettingsViewController else {
            fatalError("Initial ViewController is not of type SettingsViewController")
        }
        controller.session = session
        controller.viewModel = SettingsViewModel(session: session)
        controller.observeesViewController = try! StudentsListViewController(session: session)
        controller.observeesViewController?.selectStudentAction = { [weak controller] session, student in
            controller?.observeeSelectedAction?(session, student)
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
        self.navigationController?.navigationBar.useContextColor(ColorCoordinator.colorSchemeForParent().mainColor)

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
        observeesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
        observeesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
    }

    // ---------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        closeAction?(viewModel.session)
    }

    @objc func actionAddStudent() {
        let title = NSLocalizedString("Add Student", comment: "")
        let message = NSLocalizedString("Input the student pairing code provided to you.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = NSLocalizedString("Pairing Code", comment: "")
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in }))
        present(alert, animated: true, completion: nil)

        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] action in
            guard let textField = alert.textFields?.first, let code = textField.text else { return }
            self?.addPairingCode(code: code)
        }))
    }

    private func addPairingCode(code: String) {
        guard let session = session else { return }
        try? SettingsAPIClient.shared.addPairingCode(session, observerID: session.user.id, pairingCode: code) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in }))
                    self?.present(alert, animated: true, completion: nil)
                }
                else {
                    self?.observeesViewController?.refresh()
                }
            }
        }
    }
}
