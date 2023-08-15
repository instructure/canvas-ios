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

open class SyllabusViewController: UIViewController, CoreWebViewLinkDelegate {
    public var courseID = ""
    public let env = AppEnvironment.shared
    public let refreshControl = CircleRefreshControl()
    public var webView = CoreWebView()

    public lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    public static func create(courseID: String) -> SyllabusViewController {
        let controller = SyllabusViewController()
        controller.courseID = courseID
        return controller
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        webView.backgroundColor = .backgroundLightest
        webView.scrollView.refreshControl = refreshControl
        webView.linkDelegate = self

        view.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: view)
        courses.refresh()
    }

    func update() {
        if let html = courses.first?.syllabusBody, !html.isEmpty {
            webView.loadHTMLString(html)
            webView.accessibilityIdentifier = "syllabusBody"
        }
    }

    @objc func refresh() {
        courses.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
}
