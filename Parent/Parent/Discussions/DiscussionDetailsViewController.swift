//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import UIKit
import Core

class DiscussionDetailsViewController: UIViewController, CoreWebViewLinkDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()

    var courseID = ""
    let env = AppEnvironment.shared
    var topicID = ""
    var studentID = ""

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var topic = env.subscribe(GetDiscussionTopic(context: .course(courseID), topicID: topicID)) { [weak self] in
        self?.update()
    }

    static func create(studentID: String, courseID: String, topicID: String) -> DiscussionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.studentID = studentID
        controller.topicID = topicID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.linkDelegate = self

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        titleLabel.text = ""

        course.refresh()
        topic.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let color = ColorScheme.observee(studentID).color
        navigationController?.navigationBar.useContextColor(color)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc func refresh() {
        course.refresh(force: true)
        topic.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    func updateNavBar() {
        title = course.first?.name
    }

    func update() {
        guard let topic = topic.first else { return }

        titleLabel.text = topic.title
        webView.loadHTMLString(DiscussionHTML.string(for: topic), baseURL: topic.htmlURL)
    }
}
