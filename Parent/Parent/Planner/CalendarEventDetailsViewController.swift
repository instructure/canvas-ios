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
import UserNotifications
import Core
import SwiftUI

class CalendarEventDetailsViewController: UIViewController, ColoredNavViewProtocol, CoreWebViewLinkDelegate {
    @IBOutlet weak var dateHeadingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionHeadingLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var locationHeadingLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var reminderDateButton: UIButton!
    @IBOutlet weak var reminderHeadingLabel: UILabel!
    @IBOutlet weak var reminderMessageLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()
    let titleSubtitleView = TitleSubtitleView.create()
    var selectedDate: Date?
    private var minDate = Clock.now
    private var maxDate = Clock.now

    var color: UIColor?
    let env = AppEnvironment.shared
    var eventID = ""
    var studentID = ""

    lazy var events = env.subscribe(GetCalendarEvent(eventID: eventID)) { [weak self] in
        self?.update()
    }

    static func create(studentID: String, eventID: String) -> CalendarEventDetailsViewController {
        let controller = loadFromStoryboard()
        controller.eventID = eventID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Event Details", comment: ""))
        updateNavBar(subtitle: nil, color: ColorScheme.observee(studentID).color)
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.linkDelegate = self

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        dateHeadingLabel.text = NSLocalizedString("Date", comment: "")
        dateLabel.text = ""
        descriptionHeadingLabel.text = NSLocalizedString("Description", comment: "")
        locationHeadingLabel.text = NSLocalizedString("Location", comment: "")
        locationView.isHidden = true
        titleLabel.text = ""

        reminderHeadingLabel.text = NSLocalizedString("Remind Me", comment: "")
        reminderMessageLabel.text = NSLocalizedString("Set a date and time to be notified of this event.", comment: "")
        reminderSwitch.accessibilityLabel = NSLocalizedString("Remind Me", comment: "")
        reminderSwitch.isEnabled = false
        reminderDateButton.isEnabled = false
        reminderDateButton.isHidden = true
        reminderDateButton.setTitleColor(Brand.shared.primary, for: .normal)
        minDate = Clock.now.addMinutes(1)
        maxDate = Clock.now.addYears(1)

        events.refresh()
        NotificationManager.shared.getReminder(eventID) { [weak self] request in performUIUpdate {
            guard let self = self else { return }
            let date = (request?.trigger as? UNCalendarNotificationTrigger).flatMap {
                Calendar.current.date(from: $0.dateComponents)
            }
            if let date = date {
                self.selectedDate = date
                self.reminderSwitch.isOn = true
                self.reminderDateButton.setTitle(date.dateTimeString, for: .normal)
                self.reminderDateButton.isHidden = false
            }
        } }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let color = ColorScheme.observee(studentID).color
        navigationController?.navigationBar.useContextColor(color)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc func refresh() {
        events.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    func update() {
        guard let event = events.first else { return }
        if let title = event.contextName {
            setupTitleViewInNavbar(title: title)
        }

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
        reminderSwitch.isEnabled = true
        reminderDateButton.isEnabled = true
        if let html = event.details, !html.isEmpty {
            descriptionView.isHidden = false
            webView.loadHTMLString(html, baseURL: event.htmlURL)
        } else {
            descriptionView.isHidden = true
        }
    }

    @IBAction func reminderSwitchChanged() {
        guard let event = events.first else { return }
        if reminderSwitch.isOn {
            minDate = Clock.now.addMinutes(1)
            maxDate = Clock.now.addYears(1)
            let defaultDate = max(minDate, min(maxDate,
                event.startAt?.addMinutes(-60) ?? Clock.now.addDays(7)
            ))
            NotificationManager.shared.requestAuthorization(options: [.alert, .sound]) { success, error in performUIUpdate {
                guard error == nil && success else {
                    self.reminderSwitch.setOn(false, animated: true)
                    return self.showPermissionError(.notifications)
                }
                self.reminderDateButton.setTitle(defaultDate.dateTimeString, for: .normal)
                self.selectedDate = defaultDate
                UIView.animate(withDuration: 0.2) {
                    self.reminderDateButton.isHidden = false
                }
                self.reminderDateChanged(selectedDate: self.selectedDate)
            } }
        } else {
            NotificationManager.shared.removeReminder(eventID)
            UIView.animate(withDuration: 0.2) {
                self.reminderDateButton.isHidden = true
                if self.presentedViewController is CoreHostingController<CoreDatePickerActionSheetCard> {
                    self.presentedViewController?.dismiss(animated: true)
                }
            }
        }
    }

    @IBAction func reminderButtonTapped() {
        let dateBinding = Binding(get: { self.selectedDate },
                                  set: { self.reminderDateChanged(selectedDate: $0) })
        CoreDatePicker.showDatePicker(for: dateBinding, minDate: minDate, maxDate: maxDate, from: self)
    }

    @IBAction func reminderDateChanged(selectedDate: Date?) {
        guard let selectedDate = selectedDate, let event = events.first else { return }
        NotificationManager.shared.setReminder(for: event, at: selectedDate, studentID: studentID) { error in performUIUpdate {
            if error == nil {
                self.reminderDateButton.setTitle(selectedDate.dateTimeString, for: .normal)
            } else {
                self.reminderSwitch.setOn(false, animated: true)
                self.reminderSwitchChanged()
            }
        } }
    }
}
