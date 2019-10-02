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

class CourseDetailsViewController: UIViewController {
    @IBOutlet weak var menu: HorizontalMenuView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
    private var gradesViewController: GradesViewController!
    private var syllabusViewController: Core.SyllabusViewController!
    @IBOutlet weak var containerA: UIView!
    @IBOutlet weak var containerB: UIView!
    var courseID: String = ""
    var studentID: String = ""

    enum MenuItem: Int {
        case grades, syllabus
    }

    static func create(courseID: String, studentID: String) -> CourseDetailsViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)

        configureMenu()
        configureGrades()
        configureSyllabus()
        scrollView.delegate = self
    }

    func configureMenu() {
        menu.delegate = self
        menuHeight.constant = 1
    }

    func configureGrades() {
        gradesViewController = GradesViewController.create(courseID: courseID, studentID: studentID)
        embed(gradesViewController, in: containerA)
    }

    func configureSyllabus() {
        syllabusViewController = Core.SyllabusViewController.create(courseID: courseID)
        embed(syllabusViewController, in: containerB)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let ratio = self.scrollView.contentOffsetRatio
        coordinator.animate(alongsideTransition: { [weak self] _ in
            ratio.x >= 0.5 ? self?.showSyllabus() : self?.showGrades()
            self?.menu.reload()
        }, completion: nil)
    }

    func showGrades() {
        scrollView.scrollRectToVisible(containerA.frame, animated: true)
    }

    func showSyllabus() {
        scrollView.scrollRectToVisible(containerB.frame, animated: true)
    }
}

extension CourseDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if containerB.frame.contains(scrollView.contentOffset) {
            menu.selectMenuItem(at: IndexPath(row: MenuItem.syllabus.rawValue, section: 0), animated: true)
        } else {
            menu.selectMenuItem(at: IndexPath(row: MenuItem.grades.rawValue, section: 0), animated: true)
        }
    }
}

extension CourseDetailsViewController: HorizontalMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .grades: identifier = "grades"
        case .syllabus: identifier = "syllabus"
        }
        return "CourseDetail.\(identifier)MenuItem"
    }

    var selectedColor: UIColor? {
        return Brand.shared.buttonPrimaryBackground
    }

    var maxItemWidth: CGFloat {
        return 200
    }

    var measurementFont: UIFont {
        return .scaledNamedFont(.semibold16)
    }

    func menuItemCount() -> Int {
        return 2
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .grades:
            return NSLocalizedString("Grades", comment: "")
        case .syllabus:
            return NSLocalizedString("Syllabus", comment: "")
        }
    }

    func didSelectItem(at: IndexPath) {
        guard let item = MenuItem(rawValue: at.row) else { return }
        switch item {
        case .grades:
            showGrades()
        case .syllabus:
            showSyllabus()
        }
    }
}
