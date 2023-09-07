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
import WebKit
import mobile_offline_downloader_ios

public class LTIWebViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var webView: CoreWebView!
    @IBOutlet weak var oldLTIContainer: UIView!
    let refreshControl = CircleRefreshControl()
    let env = AppEnvironment.shared
    public var tools: LTITools!
    public var color: UIColor?
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
    public var name: String?

    public var moduleItem: ModuleItem?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }

    lazy var courses = courseID.flatMap { env.subscribe(GetCourse(courseID: $0, include: [])) { [weak self] in
        self?.updateNavBar()
    }}

    var courseID: String? {
        guard tools.context.contextType == .course else { return nil }
        return tools.context.id
    }

    public static func create(tools: LTITools, name: String? = nil) -> Self {
        let controller = loadFromStoryboard()
        controller.tools = tools
        controller.name = name
        return controller
    }

    public static func create(tools: LTITools, moduleItem: ModuleItem) -> Self {
        let controller = loadFromStoryboard()
        controller.tools = tools
        controller.moduleItem = moduleItem
        controller.title = moduleItem.title
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        webView.scrollView.refreshControl = refreshControl
        setupTitleViewInNavbar(title: NSLocalizedString("External Tool", bundle: .core, comment: ""))
        // try to get a more descriptive name of the tool
        refresh()
        webView.linkDelegate = self
        colors.refresh()
        courses?.refresh()
    }

    func loadLTI(url: URL) {
        Analytics.shared.logEvent("external_tool_launched", parameters: ["launchUrl": url])
        webView.load(URLRequest(url: url))
    }

    func updateNavBar() {
        let course = courses?.first
        updateNavBar(subtitle: course?.name, color: course?.color)
    }

    @objc func refresh() {
        spinnerView.isHidden = false
        tools.getSessionlessLaunch { [weak self] response in
            performUIUpdate {
                guard let response = response else {
                    self?.showOldLTI()
                    return
                }

                let url = response.url.appendingQueryItems(URLQueryItem(name: "platform", value: "mobile"))
                if response.name == "Google Apps" {
                    self?.showOldLTI()
                } else {
                    self?.loadLTI(url: url)
                }
                self?.refreshControl.endRefreshing()
            }
        }
    }

    func showOldLTI() {
        spinnerView.isHidden = true
        var controller: LTIViewController?
        if let moduleItem = moduleItem {
            controller = LTIViewController.create(tools: tools, moduleItem: moduleItem)
        } else {
            controller = LTIViewController.create(tools: tools, name: name)
        }

        guard let controller = controller else { return }
        webView.isHidden = true
        oldLTIContainer.isHidden = false
        controller.willMove(toParent: self)
        controller.view.frame = oldLTIContainer.bounds
        oldLTIContainer.addSubview(controller.view)
        controller.view.leadingAnchor.constraint(equalTo: oldLTIContainer.leadingAnchor, constant: 0).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: oldLTIContainer.trailingAnchor, constant: 0).isActive = true
        controller.view.topAnchor.constraint(equalTo: oldLTIContainer.topAnchor, constant: 0).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: oldLTIContainer.bottomAnchor, constant: 0).isActive = true
        oldLTIContainer.layoutIfNeeded()
        controller.didMove(toParent: self)
    }
}

extension LTIWebViewController: CoreWebViewLinkDelegate {

    public func finishedNavigation() {
        spinnerView.isHidden = true
        UIAccessibility.post(notification: .screenChanged, argument: titleSubtitleView)
    }
}
