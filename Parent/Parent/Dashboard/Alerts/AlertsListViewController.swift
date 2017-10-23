//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit


import CoreData

import CanvasCore
import ReactiveSwift

class AlertsListViewController: FetchedTableViewController<Alert> {
    let session: Session
    let observeeID: String

    init(session: Session, observeeID: String) throws {
        self.session = session
        self.observeeID = observeeID

        super.init()

        let emptyView = TableEmptyView.nibView()
        emptyView.textLabel.text = NSLocalizedString("Caught up on Alerts", comment: "Empty Alerts Text")
        emptyView.imageView?.image = UIImage(named: "empty_alerts")
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "alerts_empty_view"

        self.emptyView = emptyView

        let collection = try Alert.collectionOfObserveeAlerts(session, observeeID: observeeID)
        let refresher = try Alert.refresher(session, observeeID: observeeID)

        let scheme = ColorCoordinator.colorSchemeForStudentID(observeeID)
        prepare(collection, refresher: refresher, viewModelFactory: { alert in
            AlertCellViewModel(alert: alert, highlightColor: scheme.highlightCellColor, session: session)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.defaultTableViewBackgroundColor()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .default, title: NSLocalizedString("Dismiss", comment: "")) { [unowned self] action, indexPath in
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
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

        if let routeURL = Router.sharedInstance.alertRoute(studentID: observeeID, alertAssetPath: alert.assetPath) {
            Router.sharedInstance.route(self, toURL: routeURL, modal: true)
        }
    }
}
