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
import UserNotifications

class NotificationCategoriesViewController: UIViewController, ErrorViewController {
    var channelID: String = ""
    var channelType = CommunicationChannelType.push
    let env = AppEnvironment.shared
    var isNotificationsEnabled = false
    var sections: [(index: Int, name: String, rows: [NotificationCategory])] = []
    var selectedCategory: (String, [String])?

    let tableView = UITableView(frame: .zero, style: .grouped)

    lazy var categories = env.subscribe(GetNotificationCategories(channelID: channelID)) { [weak self] in
        self?.reloadData()
    }

    static func create(title: String, channelID: String, type: CommunicationChannelType) -> NotificationCategoriesViewController {
        let controller = NotificationCategoriesViewController()
        controller.channelID = channelID
        controller.channelType = type
        controller.isNotificationsEnabled = type != .push
        controller.title = title
        return controller
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .backgroundGrouped
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.registerHeaderFooterView(GroupedSectionFooterView.self, fromNib: false)
        tableView.registerHeaderFooterView(GroupedSectionHeaderView.self, fromNib: false)
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.registerCell(SwitchTableViewCell.self)
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        refresh()
    }

    @objc func refresh(sender: Any? = nil) {
        let force = sender != nil
        categories.refresh(force: force)

        guard channelType == .push else { return }
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in DispatchQueue.main.async {
            self?.isNotificationsEnabled = settings.authorizationStatus == .authorized
            self?.reloadData()
        } }
    }

    func reloadData() {
        if let error = categories.error {
            return showError(error)
        }
        var groups: [String: (index: Int, name: String, rows: [NotificationCategory])] = [:]
        if isNotificationsEnabled {
            for category in categories {
                guard let (position, _, section) = categoryMap[category.category] else { continue }
                if groups[section] == nil { groups[section] = (index: position, name: section, rows: []) }
                groups[section]?.rows.append(category)
            }
            sections = groups.values.sorted { $0.index < $1.index }
        }
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    lazy var categoryMap: [String: (Int, String, String)] = {
        let courseActivities = NSLocalizedString("Course Activities", bundle: .core, comment: "")
        let discussions = NSLocalizedString("Discussions", bundle: .core, comment: "")
        let conversations = NSLocalizedString("Conversations", bundle: .core, comment: "")
        let scheduling = NSLocalizedString("Scheduling", bundle: .core, comment: "")
        let groups = NSLocalizedString("Groups", bundle: .core, comment: "")
        let conferences = NSLocalizedString("Conferences", bundle: .core, comment: "")
        let alerts = NSLocalizedString("Alerts", bundle: .core, comment: "")

        var map = [
            "announcement": (0, NSLocalizedString("Announcement", bundle: .core, comment: ""), courseActivities),
            "appointment_availability": (3, NSLocalizedString("Appointment Availability", bundle: .core, comment: ""), scheduling),
            "appointment_cancelations": (3, NSLocalizedString("Appointment Cancellations", bundle: .core, comment: ""), scheduling),
            "calendar": (3, NSLocalizedString("Calendar", bundle: .core, comment: ""), scheduling),
            "conversation_message": (2, NSLocalizedString("Conversation Message", bundle: .core, comment: ""), conversations),
            "course_content": (0, NSLocalizedString("Course Content", bundle: .core, comment: ""), courseActivities),
            "due_date": (0, NSLocalizedString("Due Date", bundle: .core, comment: ""), courseActivities),
            "grading": (0, NSLocalizedString("Grading", bundle: .core, comment: ""), courseActivities),
            "invitation": (0, NSLocalizedString("Invitation", bundle: .core, comment: ""), courseActivities),
            "student_appointment_signups": (3, NSLocalizedString("Student Appointment Signups", bundle: .core, comment: ""), scheduling),
            "submission_comment": (0, NSLocalizedString("Submission Comment", bundle: .core, comment: ""), courseActivities),
            "discussion_mention": (1, NSLocalizedString("New Mention", bundle: .core, comment: ""), discussions),
        ]

        if channelType == .push {
            return map
        }

        map.merge( [
            "all_submissions": (0, NSLocalizedString("All Submissions", bundle: .core, comment: ""), courseActivities),
            "announcement_created_by_you": (0, NSLocalizedString("Announcement Created By You", bundle: .core, comment: ""), courseActivities),
            "added_to_conversation": (2, NSLocalizedString("Added To Conversation", bundle: .core, comment: ""), conversations),
            "appointment_signups": (3, NSLocalizedString("Appointment Signups", bundle: .core, comment: ""), scheduling),
            "conversation_created": (2, NSLocalizedString("Conversation Created By Me", bundle: .core, comment: ""), conversations),
            "content_link_error": (5, NSLocalizedString("Content Link Error", bundle: .core, comment: ""), alerts),
            "discussion": (1, NSLocalizedString("Discussion", bundle: .core, comment: ""), discussions),
            "discussion_entry": (1, NSLocalizedString("Discussion Post", bundle: .core, comment: ""), discussions),
            "files": (0, NSLocalizedString("Files", bundle: .core, comment: ""), courseActivities),
            "grading_policies": (0, NSLocalizedString("Grading Policies", bundle: .core, comment: ""), courseActivities),
            "late_grading": (0, NSLocalizedString("Late Grading", bundle: .core, comment: ""), courseActivities),
            "membership_update": (4, NSLocalizedString("Membership Update", bundle: .core, comment: ""), groups),
            "other": (5, NSLocalizedString("Administrative Notifications", bundle: .core, comment: ""), alerts),
        ]) { (_, new) in new }
        return map
    }()
}

extension NotificationCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard isNotificationsEnabled else { return 1 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard isNotificationsEnabled else { return nil }
        let header: GroupedSectionHeaderView = tableView.dequeueHeaderFooter()
        header.titleLabel.text = sections[section].name
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard !isNotificationsEnabled else { return nil }
        let footer: GroupedSectionFooterView = tableView.dequeueHeaderFooter()
        footer.titleLabel.text = NSLocalizedString("Notifications are currently disabled in Settings. Tap to enable them again.", bundle: .core, comment: "")
        return footer
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard !isNotificationsEnabled else { return 0 }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isNotificationsEnabled else { return 1 }
        return sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard isNotificationsEnabled else {
            let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Enable Push Notifications", bundle: .core, comment: "")
            cell.accessibilityIdentifier = "NotificationCategories.enableNotificationsCell"
            return cell
        }

        let row = sections[indexPath.section].rows[indexPath.row]
        switch channelType {
        case .email:
            let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
            cell.accessibilityIdentifier = "NotificationCategories.\(row.category)Cell"
            cell.backgroundColor = .backgroundLightest
            cell.textLabel?.text = categoryMap[row.category]?.1
            cell.detailTextLabel?.text = row.frequency.name
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            let cell: SwitchTableViewCell = tableView.dequeue(for: indexPath)
            cell.accessibilityIdentifier = "NotificationCategories.\(row.category)Toggle"
            cell.backgroundColor = .backgroundLightest
            cell.textLabel?.text = categoryMap[row.category]?.1
            cell.toggle.isOn = row.frequency != .never
            cell.onToggleChange = { [weak self] toggle in
                guard let row = self?.sections[indexPath.section].rows[indexPath.row] else { return }
                self?.update(row.category, notifications: row.notifications, frequency: toggle.isOn ? .immediately : .never)
            }
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard isNotificationsEnabled else {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            env.loginDelegate?.openExternalURL(url)
            return
        }

        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if let toggle = cell as? SwitchTableViewCell {
            toggle.toggle.setOn(!toggle.toggle.isOn, animated: true)
            toggle.onToggleChange(toggle.toggle)
        } else {
            let row = sections[indexPath.section].rows[indexPath.row]
            selectedCategory = (row.category, row.notifications)
            show(ItemPickerViewController.create(
                title: categoryMap[row.category]?.1 ?? "",
                sections: [ ItemPickerSection(items: NotificationFrequency.allCases.map { frequency in
                    ItemPickerItem(title: frequency.name, subtitle: frequency.label)
                }), ],
                selected: NotificationFrequency.allCases.firstIndex(of: row.frequency)
                    .flatMap { IndexPath(row: $0, section: 0) },
                delegate: self
            ), sender: self)
        }
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
