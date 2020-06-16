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

class StudentSyllabusViewController: HorizontalMenuViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate {
    let titleSubtitleView = TitleSubtitleView.create()
    lazy var summary = SyllabusSummaryViewController.create(courseID: courseID)
    lazy var syllabus = SyllabusViewController.create(courseID: courseID)

    lazy var viewControllers: [UIViewController] = [ syllabus, summary ]

    var courseID: String = ""
    var color: UIColor?
    let env = AppEnvironment.shared

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }
    lazy var settings = env.subscribe(GetCourseSettings(courseID: courseID)) { [weak self] in
        self?.update()
    }

    static func create(courseID: String) -> StudentSyllabusViewController {
        let controller = StudentSyllabusViewController(nibName: nil, bundle: nil)
        controller.courseID = courseID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTitleViewInNavbar(title: NSLocalizedString("Course Syllabus", comment: ""))
        view.backgroundColor = UIColor.named(.backgroundLightest)

        settings.refresh()
        colors.refresh()
        course.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    func update() {
        guard !colors.pending, let course = course.first, !settings.pending else { return }
        updateNavBar(subtitle: course.name, color: course.color)
        if settings.first?.syllabusCourseSummary != true {
            viewControllers.removeAll { $0 === summary }
        }
        if course.syllabusBody?.isEmpty != false {
            viewControllers.removeAll { $0 === syllabus }
        }
        layoutViewControllers()
        reload()
    }
}

extension StudentSyllabusViewController: HorizontalPagedMenuDelegate {
    var menuItemSelectedColor: UIColor? { color }

    func accessibilityIdentifier(at: IndexPath) -> String {
        return viewControllers.count > at.row && viewControllers[at.row] === syllabus
            ? "Syllabus.syllabusMenuItem"
            : "Syllabus.assignmentsMenuItem"
    }

    func menuItemTitle(at: IndexPath) -> String {
        return viewControllers.count > at.row && viewControllers[at.row] === syllabus
            ? NSLocalizedString("Syllabus", comment: "")
            : NSLocalizedString("Summary", comment: "")
    }
}
