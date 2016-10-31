//
//  AlertsViewController.swift
//  Parent
//
//  Created by Ben Kraus on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import ObserverAlertKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import ReactiveCocoa
import Armchair

class AlertsListViewController: Alert.TableViewController {
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

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .Default, title: NSLocalizedString("Dismiss", comment: "")) { [unowned self] action, indexPath in
            tableView.setEditing(false, animated: true)
            let alert = self.collection[indexPath]
            alert.dismiss(self.session)
        }
        return [action]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        let alert = self.collection[indexPath]
        alert.markAsRead(session)
        Armchair.userDidSignificantEvent(true)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        if let routeURL = Router.sharedInstance.alertRoute(studentID: observeeID, alertAssetPath: alert.assetPath) {
            Router.sharedInstance.route(self, toURL: routeURL, modal: true)
        }
    }
}
