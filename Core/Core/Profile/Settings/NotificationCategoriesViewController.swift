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

import Foundation
import UIKit

class NotificationCategoriesViewController: UIViewController, ErrorViewController {
    var channelID: String = ""
    var channelType = CommunicationChannelType.push
    let env = AppEnvironment.shared
    var selectedCategory: (String, [String])?

    let tableView = UITableView(frame: .zero, style: .grouped)

    lazy var categories = env.subscribe(GetNotificationCategories(channelID: channelID)) { [weak self] in
        self?.reloadData()
    }

    var sections: [(index: Int, name: String, rows: [NotificationCategory])] = []
    lazy var categoryMap: [String: (Int, String, String)] = {
        let courseActivities = NSLocalizedString("Course Activities", bundle: .core, comment: "")
        let discussions = NSLocalizedString("Discussions", bundle: .core, comment: "")
        let conversations = NSLocalizedString("Conversations", bundle: .core, comment: "")
        let scheduling = NSLocalizedString("Scheduling", bundle: .core, comment: "")
        let groups = NSLocalizedString("Groups", bundle: .core, comment: "")
        let conferences = NSLocalizedString("Conferences", bundle: .core, comment: "")
        let alerts = NSLocalizedString("Alerts", bundle: .core, comment: "")

        return [
            "course_content":              (0, NSLocalizedString("Course Content", bundle: .core, comment: ""), courseActivities),
            "files":                       (0, NSLocalizedString("Files", bundle: .core, comment: ""), courseActivities),
            "all_submissions":             (0, NSLocalizedString("All Submissions", bundle: .core, comment: ""), courseActivities),
            "submission_comment":          (0, NSLocalizedString("Submission Comment", bundle: .core, comment: ""), courseActivities),
            "announcement":                (0, NSLocalizedString("Announcement", bundle: .core, comment: ""), courseActivities),
            "announcement_created_by_you": (0, NSLocalizedString("Announcement Created By You", bundle: .core, comment: ""), courseActivities),
            "grading":                     (0, NSLocalizedString("Grading", bundle: .core, comment: ""), courseActivities),
            "due_date":                    (0, NSLocalizedString("Due Date", bundle: .core, comment: ""), courseActivities),
            "late_grading":                (0, NSLocalizedString("Late Grading", bundle: .core, comment: ""), courseActivities),
            "invitation":                  (0, NSLocalizedString("Invitation", bundle: .core, comment: ""), courseActivities),
            "grading_policies":            (0, NSLocalizedString("Grading Policies", bundle: .core, comment: ""), courseActivities),

            "discussion_entry": (1, NSLocalizedString("Discussion Post", bundle: .core, comment: ""), discussions),
            "discussion":       (1, NSLocalizedString("Discussion", bundle: .core, comment: ""), discussions),

            "added_to_conversation": (2, NSLocalizedString("Added To Conversation", bundle: .core, comment: ""), conversations),
            "conversation_message":  (2, NSLocalizedString("Conversation Message", bundle: .core, comment: ""), conversations),
            "conversation_created":  (2, NSLocalizedString("Conversation Created By Me", bundle: .core, comment: ""), conversations),

            "appointment_availability":    (3, NSLocalizedString("Appointment Availability", bundle: .core, comment: ""), scheduling),
            "appointment_signups":         (3, NSLocalizedString("Appointment Signups", bundle: .core, comment: ""), scheduling),
            "appointment_cancelations":    (3, NSLocalizedString("Appointment Cancellations", bundle: .core, comment: ""), scheduling),
            "student_appointment_signups": (3, NSLocalizedString("Student Appointment Signups", bundle: .core, comment: ""), scheduling),
            "calendar":                    (3, NSLocalizedString("Calendar", bundle: .core, comment: ""), scheduling),

            "membership_update": (4, NSLocalizedString("Membership Update", bundle: .core, comment: ""), groups),

            "other":              (5, NSLocalizedString("Administrative Notifications", bundle: .core, comment: ""), alerts),
            "content_link_error": (5, NSLocalizedString("Content Link Error", bundle: .core, comment: ""), alerts),
        ]
    }()

    func reloadData() {
        var groups: [String: (index: Int, name: String, rows: [NotificationCategory])] = [:]
        for category in categories {
            guard let (position, _, section) = categoryMap[category.category] else { continue }
            if groups[section] == nil { groups[section] = (index: position, name: section, rows: []) }
            groups[section]?.rows.append(category)
        }
        sections = groups.values.sorted { $0.index < $1.index }
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    static func create(channelID: String, type: CommunicationChannelType) -> NotificationCategoriesViewController {
        let controller = NotificationCategoriesViewController()
        controller.channelID = channelID
        controller.channelType = type
        return controller
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Notification Preferences", comment: "")

        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)

        refresh()
    }

    @objc func refresh(sender: Any? = nil) {
        let force = sender != nil
        categories.refresh(force: force)
    }
}

extension NotificationCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        switch channelType {
        case .email:
            cell.detailTextLabel?.text = row.frequency.name
            cell.detailTextLabel?.textColor = .named(.textDark)
            cell.detailTextLabel?.font = .scaledNamedFont(.semibold16)
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityIdentifier = "NotificationCategories.\(row.category)Cell"
        default:
            let toggle = UISwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            toggle.isOn = row.frequency != .never
            toggle.tag = indexPath.section * 1000 + indexPath.row
            toggle.onTintColor = Brand.shared.primary
            toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
            cell.accessoryView = toggle
            cell.accessibilityIdentifier = "NotificationCategories.\(row.category)Toggle"
        }
        cell.textLabel?.text = categoryMap[row.category]?.1
        cell.textLabel?.textColor = .named(.textDarkest)
        cell.textLabel?.font = .scaledNamedFont(.semibold16)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if let toggle = cell.accessoryView as? UISwitch {
            toggle.setOn(!toggle.isOn, animated: true)
            toggleChanged(toggle)
        } else {
            let row = sections[indexPath.section].rows[indexPath.row]
            selectedCategory = (row.category, row.notifications)
            show(ItemPickerViewController.create(
                title: categoryMap[row.category]?.1 ?? "",
                sections: [ ItemPickerSection(items: NotificationFrequency.allCases.map { frequency in
                    ItemPickerItem(title: frequency.name, subtitle: frequency.label)
                }) ],
                selected: NotificationFrequency.allCases.firstIndex(of: row.frequency)
                    .flatMap { IndexPath(row: $0, section: 0) },
                delegate: self
            ), sender: self)
        }
    }

    @objc func toggleChanged(_ toggle: UISwitch) {
        let indexPath = IndexPath(row: toggle.tag % 1000, section: toggle.tag / 1000)
        let row = sections[indexPath.section].rows[indexPath.row]
        update(row.category, notifications: row.notifications, frequency: toggle.isOn ? .immediately : .never)
    }

    func update(_ category: String, notifications: [String], frequency: NotificationFrequency) {
        let useCase = PutNotificationCategory(channelID: channelID, category: category, notifications: notifications, frequency: frequency)
        useCase.fetch { [weak self] (response, _, error) in
            if let error = error {
                self?.showError(error)
            } else if response == nil {
                self?.showError(NSError.instructureError(
                    NSLocalizedString("Could not save notification preference", bundle: .core, comment: "")
                ))
            }
        }
    }
}

extension NotificationCategoriesViewController: ItemPickerDelegate {
    func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath) {
        guard let (category, notifications) = selectedCategory else { return }
        update(category, notifications: notifications, frequency: NotificationFrequency.allCases[indexPath.row])
    }
}
