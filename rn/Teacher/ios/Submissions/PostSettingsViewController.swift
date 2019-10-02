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

class PostSettingsViewController: UIViewController {
    @IBOutlet weak var menu: HorizontalMenuView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
    private var postGradesViewController: PostGradesViewController!
    private var hideGradesViewController: HideGradesViewController!
    @IBOutlet weak var containerA: UIView!
    @IBOutlet weak var containerB: UIView!
    var courseID: String = ""
    var assignmentID: String = ""

    enum MenuItem: Int {
        case post, hide
    }

    static func create(courseID: String, assignmentID: String) -> PostSettingsViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.assignmentID = assignmentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Post Settings", comment: "")
        configureMenu()
        configurePost()
        configureHide()
        scrollView.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.white

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
    }

    func configureMenu() {
        menu.delegate = self
        menuHeight.constant = 1
    }

    func configurePost() {
        postGradesViewController = PostGradesViewController.create(courseID: courseID, assignmentID: assignmentID)
        embed(postGradesViewController, in: containerA)
    }

    func configureHide() {
        hideGradesViewController = HideGradesViewController.create(courseID: courseID, assignmentID: assignmentID)
        embed(hideGradesViewController, in: containerB)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let ratio = self.scrollView.contentOffsetRatio
        coordinator.animate(alongsideTransition: { [weak self] _ in
            ratio.x >= 0.5 ? self?.showHide() : self?.showPost()
            self?.menu.reload()
        }, completion: nil)
    }

    func showPost() {
        scrollView.scrollRectToVisible(containerA.frame, animated: true)
    }

    func showHide() {
        scrollView.scrollRectToVisible(containerB.frame, animated: true)
    }
}

extension PostSettingsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if containerB.frame.contains(scrollView.contentOffset) {
            menu.selectMenuItem(at: IndexPath(row: MenuItem.hide.rawValue, section: 0), animated: true)
        } else {
            menu.selectMenuItem(at: IndexPath(row: MenuItem.post.rawValue, section: 0), animated: true)
        }
    }
}

extension PostSettingsViewController: HorizontalMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .post: identifier = "post"
        case .hide: identifier = "hide"
        }
        return "PostSettings.\(identifier)MenuItem"
    }

    var selectedColor: UIColor? {
        return Brand.shared.buttonPrimaryBackground
    }

    var maxItemWidth: CGFloat {
        return 200
    }

    var measurementFont: UIFont {
        return .scaledNamedFont(.semibold14)
    }

    func menuItemCount() -> Int {
        return 2
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .post:
            return NSLocalizedString("Post Grades", comment: "")
        case .hide:
            return NSLocalizedString("Hide Grades", comment: "")
        }
    }

    func didSelectItem(at: IndexPath) {
        guard let item = MenuItem(rawValue: at.row) else { return }
        switch item {
        case .post:
            showPost()
        case .hide:
            showHide()
        }
    }
}
