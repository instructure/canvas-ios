//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class PostSettingsViewController: HorizontalMenuViewController {
    private var postGradesViewController: PostGradesViewController!
    private var hideGradesViewController: HideGradesViewController!
    var courseID: String = ""
    var assignmentID: String = ""
    var viewControllers: [UIViewController] = []

    enum MenuItem: Int {
        case post, hide
    }

    static func create(courseID: String, assignmentID: String) -> PostSettingsViewController {
        let controller = PostSettingsViewController(nibName: nil, bundle: nil)
        controller.courseID = courseID
        controller.assignmentID = assignmentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = String(localized: "Post Settings", bundle: .teacher)

        delegate = self
        configurePost()
        configureHide()

        navigationController?.navigationBar.useModalStyle()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: String(localized: "Back", bundle: .teacher), style: .plain, target: nil, action: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutViewControllers()
    }

    func configurePost() {
        postGradesViewController = PostGradesViewController.create(courseID: courseID, assignmentID: assignmentID)
        viewControllers.append(postGradesViewController)
    }

    func configureHide() {
        hideGradesViewController = HideGradesViewController.create(courseID: courseID, assignmentID: assignmentID)
        viewControllers.append(hideGradesViewController)
    }
}

extension PostSettingsViewController: HorizontalPagedMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .post: identifier = "post"
        case .hide: identifier = "hide"
        }
        return "PostSettings.\(identifier)MenuItem"
    }

    var menuItemSelectedColor: UIColor? {
        return Brand.shared.buttonPrimaryBackground
    }

    var measurementFont: UIFont {
        return .scaledNamedFont(.semibold14)
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .post:
            return String(localized: "Post Grades", bundle: .teacher)
        case .hide:
            return String(localized: "Hide Grades", bundle: .teacher)
        }
    }
}
