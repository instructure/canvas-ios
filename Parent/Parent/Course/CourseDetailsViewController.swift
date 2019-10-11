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

class CourseDetailsViewController: HorizontalMenuViewController {
    private var gradesViewController: GradesViewController!
    private var syllabusViewController: Core.SyllabusViewController!
    var courseID: String = ""
    var studentID: String = ""
    var viewControllers: [UIViewController] = []

    enum MenuItem: Int {
        case grades, syllabus
    }

    static func create(courseID: String, studentID: String) -> CourseDetailsViewController {
        let controller = CourseDetailsViewController(nibName: nil, bundle: nil)
        controller.courseID = courseID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)

        delegate = self
        configureGrades()
        configureSyllabus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutViewControllers()
    }

    func configureGrades() {
        gradesViewController = GradesViewController.create(courseID: courseID, studentID: studentID)
        viewControllers.append(gradesViewController)
    }

    func configureSyllabus() {
        syllabusViewController = Core.SyllabusViewController.create(courseID: courseID)
        viewControllers.append(syllabusViewController)
    }
}

extension CourseDetailsViewController: HorizontalPagedMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .grades: identifier = "grades"
        case .syllabus: identifier = "syllabus"
        }
        return "CourseDetail.\(identifier)MenuItem"
    }

    var menuItemSelectedColor: UIColor? {
        return Brand.shared.buttonPrimaryBackground
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
}
