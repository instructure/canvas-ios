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
    private var summaryViewController: Core.SyllabusActionableItemsViewController!
    var courseID: String = ""
    var studentID: String = ""
    var viewControllers: [UIViewController] = []
    var readyToLayoutTabs: Bool = false
    var didLayoutTabs: Bool = false
    var env: AppEnvironment!
    var colorScheme: ColorScheme?

    enum MenuItem: Int {
        case grades, syllabus, summary
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID, include: GetCourseRequest.defaultIncludes + [.observedUsers])) { [weak self] in
        self?.courseReady()
    }

    lazy var frontPages = env.subscribe(GetFrontPage(context: ContextModel(.course, id: courseID))) { [weak self] in
        self?.courseReady()
    }

    static func create(courseID: String, studentID: String, env: AppEnvironment = .shared) -> CourseDetailsViewController {
        let controller = CourseDetailsViewController(nibName: nil, bundle: nil)
        controller.env = env
        controller.courseID = courseID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        colorScheme = ColorCoordinator.colorSchemeForStudentID(studentID)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)

        delegate = self
        courses.refresh()
        frontPages.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readyToLayoutTabs = true
        courseReady()
    }

    func configureGrades() {
        gradesViewController = GradesViewController.create(courseID: courseID, studentID: studentID, colorDelegate: self)
        viewControllers.append(gradesViewController)
    }

    func configureSyllabus() {
        syllabusViewController = Core.SyllabusViewController.create(courseID: courseID)
        viewControllers.append(syllabusViewController)
    }

    func configureSummary() {
        summaryViewController = Core.SyllabusActionableItemsViewController(courseID: courseID, sort: GetAssignments.Sort.dueAt, colorDelegate: self)
        viewControllers.append(summaryViewController)
    }

    func configureFrontPage() {
        let vc = CoreWebViewController()
        vc.webView.loadHTMLString(frontPages.first?.body ?? "", baseURL: nil)
        viewControllers.append(vc)
    }

    func courseReady() {
        if !courses.pending && !frontPages.pending && readyToLayoutTabs, !didLayoutTabs, let course = courses.first {
            didLayoutTabs = true
            configureGrades()

            switch course.defaultView {
            case .syllabus:
                if let body = course.syllabusBody, !body.isEmpty {
                    configureSyllabus()
                    configureSummary()
                }
            case .wiki:
                if let page = frontPages.first, !page.body.isEmpty {
                    configureFrontPage()
                    configureSummary()
                }
            default: break
            }

            layoutViewControllers()
        }
    }
}

extension CourseDetailsViewController: ColorDelegate {
    var iconColor: UIColor? {
        return colorScheme?.mainColor
    }
}

extension CourseDetailsViewController: HorizontalPagedMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .grades: identifier = "grades"
        case .syllabus: identifier = "syllabus"
        case .summary: identifier = "summary"
        }
        return "CourseDetail.\(identifier)MenuItem"
    }

    var menuItemSelectedColor: UIColor? {
        return colorScheme?.mainColor
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .grades:
            return NSLocalizedString("Grades", comment: "")
        case .syllabus:
            return NSLocalizedString("Syllabus", comment: "")
        case .summary:
            return NSLocalizedString("Summary", comment: "")
        }
    }
}
