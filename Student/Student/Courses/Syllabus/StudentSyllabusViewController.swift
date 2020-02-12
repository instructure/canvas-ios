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

class StudentSyllabusViewController: HorizontalMenuViewController {

    var presenter: StudentSyllabusPresenter!
    var titleView: TitleSubtitleView!
    var courseID: String = ""
    var color: UIColor?
    var syllabus: Core.SyllabusViewController?
    var assignments: SyllabusSummaryViewController?

    var viewControllers: [UIViewController] = []

    enum MenuItem: Int {
        case syllabus, assignments
    }

    static func create(courseID: String) -> StudentSyllabusViewController {
        let vc = StudentSyllabusViewController(nibName: nil, bundle: nil)
        vc.courseID = courseID
        vc.presenter = StudentSyllabusPresenter(courseID: courseID, view: vc)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.named(.backgroundLightest)
        delegate = self
        configureTitleView()
        configureSyllabus()
        configureAssignments()
        presenter.viewIsReady()
    }

    // MARK: - Setup

    func configureTitleView() {
        titleView = TitleSubtitleView.create()
        navigationItem.titleView = titleView
        titleView.title = NSLocalizedString("Course Syllabus", comment: "")
    }

    func configureSyllabus() {
        syllabus = Core.SyllabusViewController.create(courseID: courseID)
        guard let syllabus = syllabus else { return }
        viewControllers.append(syllabus)
    }

    func configureAssignments() {
        assignments = SyllabusSummaryViewController(courseID: courseID, sort: GetAssignments.Sort.dueAt)
        guard let assignments = assignments else { return }
        viewControllers.append(assignments)
    }
}

extension StudentSyllabusViewController: StudentSyllabusViewProtocol {
    func updateNavBar(courseCode: String?, backgroundColor: UIColor?) {
        titleView.subtitle = courseCode
        navigationController?.navigationBar.useContextColor(backgroundColor)
        color = backgroundColor?.ensureContrast(against: .named(.white))
    }

    func updateMenuHeight() {
        layoutViewControllers()
        reload()
    }

    func showAssignmentsOnly() {
        if viewControllers.count > 1 { viewControllers.remove(at: 0) }
        layoutViewControllers()
        reload()
    }
}

extension StudentSyllabusViewController: HorizontalPagedMenuDelegate {
    var menuItemSelectedColor: UIColor? { color }

    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .syllabus: identifier = "syllabus"
        case .assignments: identifier = "assignments"
        }
        return "Syllabus.\(identifier)MenuItem"
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .syllabus:
            return NSLocalizedString("Syllabus", comment: "")
        case .assignments:
            return NSLocalizedString("Summary", comment: "")
        }
    }
}

extension StudentSyllabusViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        presenter.show(url, from: self)
        return true
    }
}
