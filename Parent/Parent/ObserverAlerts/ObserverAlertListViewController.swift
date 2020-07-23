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

class ObserverAlertListViewController: UIViewController {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var tableView: UITableView!

    let env = AppEnvironment.shared
    var studentID = ""

    lazy var alerts = env.subscribe(GetObserverAlerts(studentID: studentID)) { [weak self] in
        self?.update()
    }
    lazy var thresholds = env.subscribe(GetAlertThresholds(studentID: studentID)) { [weak self] in
        self?.update()
    }

    static func create(studentID: String) -> ObserverAlertListViewController {
        let controller = loadFromStoryboard()
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)

        emptyMessageLabel.text = NSLocalizedString("There's nothing to be notified of yet.", comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Alerts", comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading alerts. Pull to refresh to try again.", comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        tableView.backgroundColor = .named(.backgroundLightest)
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .named(.borderMedium)

        alerts.exhaust() // so the badge number can be accurate
        thresholds.exhaust()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scheme = ColorScheme.observee(studentID)
        navigationController?.navigationBar.useContextColor(scheme.color)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    func update() {
        loadingView.isHidden = !alerts.pending || !alerts.isEmpty || alerts.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = alerts.pending || !alerts.isEmpty || alerts.error != nil
        errorView.isHidden = alerts.error == nil
        tableView.reloadData()
        let unreadCount = alerts.filter { $0.workflowState == .unread } .count
        tabBarItem.badgeValue = unreadCount <= 0 ? nil :
            NumberFormatter.localizedString(from: NSNumber(value: unreadCount), number: .none)
    }

    @objc func refresh() {
        alerts.exhaust(force: true) { [weak self] _ in
            if self?.alerts.hasNextPage == false {
                self?.refreshControl.endRefreshing()
            }
            return true
        }
        thresholds.exhaust()
    }
}

extension ObserverAlertListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ObserverAlertListCell.self, for: indexPath)
        let alert = alerts[indexPath.row]
        let threshold = thresholds.first { $0.id == alert?.thresholdID }
            ?? thresholds.first { $0.type == alert?.alertType }
        cell.update(alert: alert, threshold: threshold?.value)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let alert = alerts[indexPath.row] else { return }
        MarkObserverAlertRead(alertID: alert.id).fetch()
        if [ .courseGradeLow, .courseGradeHigh ].contains(alert.alertType) {
            env.router.route(to: "/courses/\(alert.courseID ?? alert.contextID ?? "")/grades", from: self, options: .detail)
        } else if let url = alert.htmlURL {
            env.router.route(to: url, from: self, options: .detail)
        } else if alert.alertType == .institutionAnnouncement, let announcementID = alert.contextID {
            env.router.route(to: "/accounts/self/account_notifications/\(announcementID)", from: self, options: .detail)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = alerts[indexPath.row]?.id else { return nil }
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: NSLocalizedString("Dismiss", comment: "")) { (_, _, completed) in
                DismissObserverAlert(alertID: id).fetch { (_, _, error) in
                    completed(error == nil)
                }
            },
        ])
    }
}

class ObserverAlertListCell: UITableViewCell {
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func update(alert: ObserverAlert?, threshold: UInt?) {
        backgroundColor = .named(.backgroundLightest)
        unreadView.isHidden = alert?.workflowState != .unread
        unreadView.accessibilityLabel = NSLocalizedString("Unread", comment: "")
        typeLabel.text = alert?.alertType.title(for: threshold)
        titleLabel.text = alert?.title
        dateLabel.text = alert?.actionDate?.dateTimeString
        switch alert?.alertType {
        case .assignmentGradeHigh, .courseGradeHigh:
            typeLabel.textColor = .named(.textInfo)
            iconView.tintColor = .named(.textInfo)
            iconView.image = .icon(.info, .line)
        case .assignmentGradeLow, .assignmentMissing, .courseGradeLow:
            typeLabel.textColor = .named(.textDanger)
            iconView.tintColor = .named(.textDanger)
            iconView.image = .icon(.warning, .line)
        case .courseAnnouncement, .institutionAnnouncement, .none:
            typeLabel.textColor = .named(.textDark)
            iconView.tintColor = .named(.textDark)
            iconView.image = .icon(.info, .line)
        }
    }
}
