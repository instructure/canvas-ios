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
    lazy var students = env.subscribe(GetObservedStudents(observerID: env.currentSession?.userID ??  "")) { [weak self] in
    }

    // ---------------------------------------------
    // MARK: - IBOutlets
    // ---------------------------------------------
    @objc var logoutButton: UIBarButtonItem?
    @objc var closeButton: UIBarButtonItem?
    @objc var addButton: UIBarButtonItem?
    @IBOutlet weak var observeesContainerView: UIView!
    @objc var session: Session?
    var showAddStudentPrompt: Bool = false

    @objc let reuseIdentifier = "SettingsObserveesCell"

    // ---------------------------------------------
    // MARK: - ViewModel
    // ---------------------------------------------
    var viewModel: SettingsViewModel!
    var observeesViewController: StudentsListViewController?
    lazy var addStudentController = AddStudentController(presentingViewController: self, handler: { [weak self] error in
        if error == nil {
            self?.observeesViewController?.refresh()
            self?.students.exhaust()
        }
    })

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    static func create(env: AppEnvironment = .shared, session: Session, showAddStudentPrompt: Bool = false) -> SettingsViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.showAddStudentPrompt = showAddStudentPrompt
        controller.session = session
        controller.viewModel = SettingsViewModel(session: session)
        //  swiftlint:disable:next force_try
        controller.observeesViewController = try! StudentsListViewController(session: session)
        controller.observeesViewController?.selectStudentAction = { [weak controller] session, student in
            guard let view = controller else { return }
            env.router.route(to: .observeeThresholds(student.id), from: view)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showAddStudentPrompt {
            showAddStudentPrompt = false
            addStudentController.actionAddStudent()
        }
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    @objc func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.useContextColor(ColorScheme.observer.color)

        let addStudentButton = UIBarButtonItem(barButtonSystemItem: .add, target: addStudentController, action: #selector(addStudentController.actionAddStudent))
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
}
