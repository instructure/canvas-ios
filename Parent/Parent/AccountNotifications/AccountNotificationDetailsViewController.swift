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

class AccountNotificationDetailsViewController: UIViewController, CoreWebViewLinkDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()

    let env = AppEnvironment.shared
    var notificationID = ""
    var studentID: String?

    lazy var notifications = env.subscribe(GetAccountNotification(notificationID: notificationID)) { [weak self] in
        self?.update()
    }

    static func create(studentID: String?, notificationID: String) -> AccountNotificationDetailsViewController {
        let controller = loadFromStoryboard()
        controller.notificationID = notificationID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = NSLocalizedString("Announcement", comment: "")
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.linkDelegate = self

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        titleLabel.text = ""

        notifications.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let color = (studentID.map { ColorScheme.observee($0) } ?? ColorScheme.observer).color
        navigationController?.navigationBar.useContextColor(color)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc func refresh() {
        notifications.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    func update() {
        guard let notification = notifications.first else { return }

        titleLabel.text = notification.subject
        webView.loadHTMLString(notification.message, baseURL: env.api.baseURL
            .appendingPathComponent("accounts/self/account_notifications/\(notificationID)")
        )
    }
}
