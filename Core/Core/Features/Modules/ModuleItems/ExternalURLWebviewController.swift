//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class ExternalURLWebviewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var webView: CoreWebView!
    let refreshControl = CircleRefreshControl()
    let env = AppEnvironment.shared

    public var color: UIColor?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    public var name: String!
    public var url: URL!
    public var courseID: String?

    public lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    public lazy var courses = courseID.flatMap { env.subscribe(GetCourse(courseID: $0, include: [])) { [weak self] in
        self?.updateNavBar()
    }}

    public static func create(name: String, url: URL, courseID: String?) -> Self {
        let controller = loadFromStoryboard()
        controller.name = name
        controller.url = url
        controller.courseID = courseID
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("External URL", bundle: .core, comment: ""))
        colors.refresh()
        courses?.refresh()
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        webView.scrollView.refreshControl = refreshControl
        refresh()
        webView.linkDelegate = self

    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    public func updateNavBar() {
        let course = courses?.first
        updateNavBar(subtitle: course?.name, color: course?.color)
    }

    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }

    @objc func refresh() {
        spinnerView.isHidden = false
        env.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] response, _, _ in
            guard let self = self else { return }
            performUIUpdate {
                self.load(url: response?.session_url ?? self.url)
                self.refreshControl.endRefreshing()
                self.spinnerView.isHidden = true
            }
        }
    }
}

extension ExternalURLWebviewController: CoreWebViewLinkDelegate {

    public func finishedNavigation() {
        spinnerView.isHidden = true
        UIAccessibility.post(notification: .screenChanged, argument: titleSubtitleView)
    }
}
