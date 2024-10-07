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

import Combine
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

    private var state: InstUI.ScreenState = .loading {
        didSet {
            update()
        }
    }
    private var alerts: [ObserverAlert] = []
    private var thresholds: [AlertThreshold] = []
    private lazy var interactor = ObserverAlertsInteractor(studentID: studentID)
    private var subscriptions = Set<AnyCancellable>()

    static func create(studentID: String) -> ObserverAlertListViewController {
        let controller = loadFromStoryboard()
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        emptyMessageLabel.text = String(localized: "There's nothing to be notified of yet.", bundle: .parent)
        emptyTitleLabel.text = String(localized: "No Alerts", bundle: .parent)
        errorView.messageLabel.text = String(localized: "There was an error loading alerts. Pull to refresh to try again.", bundle: .parent)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        tableView.backgroundColor = .backgroundLightest
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium

        internalRefresh(ignoreCache: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scheme = ColorScheme.observee(studentID)
        navigationController?.navigationBar.useContextColor(scheme.color)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    @objc func refresh() {
        internalRefresh(ignoreCache: true)
    }

    // MARK: Private Methods

    private func update() {
        loadingView.isHidden = (state != .loading)
        emptyView.isHidden = (state != .empty)
        errorView.isHidden = (state != .error)
        tableView.reloadData()
        updateTabBarBadgeCount()
    }

    private func updateTabBarBadgeCount() {
        let unreadCount = alerts.filter { $0.workflowState == .unread } .count
        tabBarItem.badgeValue = unreadCount <= 0 ? nil :
            NumberFormatter.localizedString(from: NSNumber(value: unreadCount), number: .none)
    }

    private func internalRefresh(ignoreCache: Bool) {
        interactor
            .refresh(ignoreCache: ignoreCache)
            .sink { [weak self] completion in
                guard let self else { return }

                switch completion {
                case .finished:
                    state = alerts.isEmpty ? .empty : .data
                case .failure:
                    state = .error
                }
                refreshControl.endRefreshing()
            } receiveValue: { [weak self] (alerts, thresholds) in
                self?.alerts = alerts
                self?.thresholds = thresholds
            }
            .store(in: &subscriptions)
    }

    private func showItemLockedMessage() {
        let alert = UIAlertController(
            title: String(localized: "Locked", bundle: .parent),
            message: String(localized: "The linked item is no longer available.", bundle: .parent),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(String(localized: "OK", bundle: .parent), style: .cancel))
        env.router.show(alert, from: self, options: .modal())
    }
}

extension ObserverAlertListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ObserverAlertListCell.self, for: indexPath)
        let alert = alerts[indexPath.row]
        let threshold = thresholds.first { $0.id == alert.thresholdID }
            ?? thresholds.first { $0.type == alert.alertType }
        cell.update(alert: alert, threshold: threshold?.value)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = alerts[indexPath.row]

        MarkObserverAlertRead(alertID: alert.id).fetch()

        guard alert.lockedForUser == false else {
            showItemLockedMessage()
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        if [ .courseGradeLow, .courseGradeHigh ].contains(alert.alertType) {
            env.router.route(to: "/courses/\(alert.courseID ?? alert.contextID ?? "")/grades", from: self, options: .detail)
        } else if let url = alert.htmlURL {
            env.router.route(to: url, from: self, options: .detail)
        } else if alert.alertType == .institutionAnnouncement, let announcementID = alert.contextID {
            env.router.route(to: "/accounts/self/account_notifications/\(announcementID)", from: self, options: .detail)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = alerts[indexPath.row].id
        let dismissTitle = String(localized: "Dismiss", bundle: .parent)
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: dismissTitle) { [weak self] (_, _, completion) in
                self?.dismissAlert(id: id, completion: completion)
            }
        ])
    }

    private func dismissAlert(id: String, completion: @escaping (Bool) -> Void) {
        interactor.dismissAlert(id: id)
            .sink(
                receiveCompletion: {
                    switch $0 {
                    case .finished: completion(true)
                    case .failure: completion(false)
                    }
                },
                receiveValue: { [weak self] in
                    guard let self, let index = alerts.firstIndex(where: { $0.id == id }) else { return }

                    alerts.remove(at: index)
                    tableView.deleteRows(at: [.init(row: index, section: 0)], with: .automatic)
                }
            )
            .store(in: &subscriptions)
    }
}

class ObserverAlertListCell: UITableViewCell {
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func update(alert: ObserverAlert?, threshold: UInt?) {
        backgroundColor = .backgroundLightest
        unreadView.isHidden = alert?.workflowState != .unread
        unreadView.accessibilityLabel = String(localized: "Unread", bundle: .parent)
        typeLabel.text = alert?.alertType.title(for: threshold)
        titleLabel.text = alert?.title
        dateLabel.text = alert?.actionDate?.dateTimeString
        switch alert?.alertType {
        case .assignmentGradeHigh, .courseGradeHigh:
            typeLabel.textColor = .textInfo
            iconView.tintColor = .textInfo
            iconView.image = .infoLine
        case .assignmentGradeLow, .assignmentMissing, .courseGradeLow:
            typeLabel.textColor = .textDanger
            iconView.tintColor = .textDanger
            iconView.image = .warningLine
        case .courseAnnouncement, .institutionAnnouncement, .none:
            typeLabel.textColor = .textDark
            iconView.tintColor = .textDark
            iconView.image = .infoLine
        }

        if alert?.lockedForUser == true {
            updateTitleToLockedState()
            iconView.image = .lockLine
        }
    }

    private func updateTitleToLockedState() {
        var newTypeText = typeLabel.text ?? ""
        let lockedText = String(localized: "Locked", bundle: .parent)

        if newTypeText.isEmpty {
            newTypeText = lockedText
        } else {
            newTypeText.append(String(format: " • %@", lockedText))
        }

        typeLabel.text = newTypeText
    }
}
