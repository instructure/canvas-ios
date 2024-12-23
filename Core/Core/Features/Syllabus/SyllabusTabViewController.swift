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
import SwiftUI

open class SyllabusTabViewController: ScreenViewTrackableHorizontalMenuViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate {
    public let titleSubtitleView = TitleSubtitleView.create()
    public var courseID: String = ""
    public var color: UIColor?
    public let env = AppEnvironment.shared
    open lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/courses/\(courseID)/assignments/syllabus"
    )
    lazy public var viewControllers: [UIViewController] = [ syllabus, summary ]

    lazy var summary = SyllabusSummaryViewController.create(courseID: courseID)
    lazy var syllabus = SyllabusViewController.create(courseID: courseID)

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }
    lazy var settings = env.subscribe(GetCourseSettings(courseID: courseID)) { [weak self] in
        self?.update()
    }

    private var emptyPandaViewController: CoreHostingController<InteractivePanda> = {
        let vc = CoreHostingController(
            InteractivePanda(
                scene: SpacePanda(),
                title: Text("No syllabus"),
                subtitle: Text("There is no syllabus to display.")
            )
        )
        vc.view.backgroundColor = .backgroundLightest
        return vc
    }()

    public static func create(courseID: String) -> SyllabusTabViewController {
        let controller = SyllabusTabViewController(nibName: nil, bundle: nil)
        controller.courseID = courseID
        return controller
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTitleViewInNavbar(title: String(localized: "Course Syllabus", bundle: .core))
        view.backgroundColor = UIColor.backgroundLightest
        emptyPandaViewController.view.backgroundColor = .backgroundLightest
        settings.refresh()
        colors.refresh()
        course.refresh()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    func update() {
        guard !colors.pending, !course.pending, let course = course.first, !settings.pending else { return }
        updateNavBar(subtitle: course.name, color: course.color)

        layoutViewControllers()
        viewControllers = []
        if course.syllabusBody?.isEmpty == false {
            viewControllers.append(syllabus)
        }
        if settings.first?.syllabusCourseSummary == true {
            viewControllers.append(summary)
        }
        if viewControllers.isEmpty {
            addChild(emptyPandaViewController)
            emptyPandaViewController.didMove(toParent: self)
            view.addSubview(emptyPandaViewController.view)
            emptyPandaViewController.view.pin(inside: view)
        } else if emptyPandaViewController.parent != nil, emptyPandaViewController.view.superview != nil {
            emptyPandaViewController.removeFromParent()
            emptyPandaViewController.view.removeFromSuperview()
        }
        updateFrames()
        reload()
    }
}

extension SyllabusTabViewController: HorizontalPagedMenuDelegate {
    public var menuItemSelectedColor: UIColor? { color }

    public func accessibilityIdentifier(at: IndexPath) -> String {
        return viewControllers.count > at.row && viewControllers[at.row] === syllabus
            ? "Syllabus.syllabusMenuItem"
            : "Syllabus.assignmentsMenuItem"
    }

    public func menuItemTitle(at: IndexPath) -> String {
        return viewControllers.count > at.row && viewControllers[at.row] === syllabus
            ? String(localized: "Syllabus", bundle: .core)
            : String(localized: "Summary", bundle: .core)
    }
}
