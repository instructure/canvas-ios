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

class CalendarEventDetailsViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var locationHeadingLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()
    let titleSubtitleView = TitleSubtitleView.create()

    var color: UIColor?
    let env = AppEnvironment.shared
    var eventID = ""
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/calendar")

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var events = env.subscribe(GetCalendarEvent(eventID: eventID)) { [weak self] in
        self?.update()
    }

    static func create(eventID: String) -> CalendarEventDetailsViewController {
        let controller = loadFromStoryboard()
        controller.eventID = eventID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Event Details", comment: ""))
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.linkDelegate = self

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        dateLabel.text = ""
        locationHeadingLabel.text = NSLocalizedString("Location", comment: "")
        locationView.isHidden = true
        titleLabel.text = ""

        colors.refresh()
        events.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    @objc func refresh() {
        colors.refresh(force: true)
        events.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    func update() {
        guard let event = events.first else { return }
        let color = colors.first { $0.canvasContextID == event.contextRaw }
        updateNavBar(subtitle: event.contextName, color: color?.color ?? .ash)

        titleLabel.text = event.title
        if event.isAllDay {
            dateLabel.text = event.startAt?.dateOnlyString
        } else if let start = event.startAt, let end = event.endAt {
            dateLabel.text = start.intervalStringTo(end)
        } else {
            dateLabel.text = event.startAt?.dateTimeString
        }
        locationView.isHidden = event.locationName?.isEmpty != false && event.locationAddress?.isEmpty != false
        locationNameLabel.text = event.locationName
        locationAddressLabel.text = event.locationAddress
        if let html = event.details {
            webView.loadHTMLString(html, baseURL: event.htmlURL)
        }
    }
}
