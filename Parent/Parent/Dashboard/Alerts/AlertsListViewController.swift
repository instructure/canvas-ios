//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import CoreData
import CanvasCore
import ReactiveSwift
import Core

class AlertsListViewController: FetchedTableViewController<Alert> {
    @objc let session: Session
    @objc let observeeID: String

    @objc init(session: Session, observeeID: String) throws {
        self.session = session
        self.observeeID = observeeID

        super.init()

        let emptyView = TableEmptyView.nibView()
        emptyView.textLabel.text = NSLocalizedString("Caught up on Alerts", comment: "Empty Alerts Text")
        emptyView.imageView?.image = UIImage(named: "PandaNoAlerts", in: .core, compatibleWith: nil)
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "alerts_empty_view"

        self.emptyView = emptyView

        let collection = try Alert.collectionOfObserveeAlerts(session, observeeID: observeeID)
        let refresher = try Alert.refresher(session, observeeID: observeeID)

        prepare(collection, refresher: refresher, viewModelFactory: { alert in
            AlertCellViewModel(alert: alert, highlightColor: .named(.backgroundLight), session: session)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.named(.backgroundLightest)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scheme = ColorScheme.observee(observeeID)
        navigationController?.navigationBar.useContextColor(scheme.color)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .default, title: NSLocalizedString("Dismiss", comment: "")) { [unowned self] _, indexPath in
            tableView.setEditing(false, animated: true)
            let alert = self.collection[indexPath]
            alert.dismiss(self.session)
        }
        return [action]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        let alert = self.collection[indexPath]
        alert.markAsRead(session)
        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)

        if [.courseGradeLow, .courseGradeHigh].contains(alert.type) {
            AppEnvironment.shared.router.route(to: "/courses/\(alert.courseID ?? alert.contextID ?? "")/grades", from: self)
        } else if let assetPath = alert.assetPath {
            AppEnvironment.shared.router.route(to: assetPath, from: self)
        } else if alert.type == .institutionAnnouncement, let announcementID = alert.contextID {
            AppEnvironment.shared.router.route(to: "/accounts/self/users/self/account_notifications/\(announcementID)", from: self)
        }
    }
}
