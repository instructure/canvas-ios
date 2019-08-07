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
import ReactiveSwift
import CanvasCore
import TechDebt
import Core
import class CanvasCore.Tab

extension Tab {
    @objc func routingURL(_ session: Session) -> URL? {
        if isHome {
            guard let enrollment = session.enrollmentsDataSource[contextID] else { return url }
            return URL(string: enrollment.defaultViewPath)
        } else if isPages {
            return URL(string: "\(contextID.htmlPath)/pages")
        }
        return url
    }
}

extension ColorfulViewModel {
    init(session: Session, tab: Tab) {
        self.init(features: [.icon])
        
        title.value = tab.label
        icon.value = tab.icon
        color <~ session.enrollmentsDataSource.color(for: tab.contextID)
    }
}

class TabsTableViewController: FetchedTableViewController<Tab>, PageViewEventViewControllerLoggingProtocol {
    @objc let route: (UIViewController, URL)->()
    @objc let session: Session
    let contextID: ContextID

    @objc var selectedTabURL: URL?
    
    init(session: Session, contextID: ContextID, route: @escaping (UIViewController, URL)->()) throws {
        self.session = session
        self.route = route
        self.contextID = contextID
        super.init()
        
        prepare(try Tab.collection(session, contextID: contextID), refresher: try Tab.refresher(session, contextID: contextID)) { tab in ColorfulViewModel(session: session, tab: tab) }

        rac_title <~ session.enrollmentsDataSource.producer(contextID).map { $0?.name }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tab = collection[indexPath]
        CanvasAnalytics.logEvent("group_tab_selected", parameters: ["tabId": tab.id])
        if let routingURL = tab.routingURL(session) {
            route(self, routingURL)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedTabURL = selectedTabURL, let tab = collection.filter({ $0.routingURL(session) == selectedTabURL }).first, let indexPath = collection.indexPath(forObject: tab), self.splitViewController?.isCollapsed == false {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
        startTrackingTimeOnViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/groups/\(contextID.id)")
    }
    
    override func handleError(_ error: NSError) {
        guard error.code == 401 else { super.handleError(error); return }
        
        let title = NSLocalizedString("Access Denied", comment: "Access Denied from the server")
        let message = NSLocalizedString("You do not have access to this content. The Course or Group may not have started, or may have been concluded.", comment: "Error message for an unauthorized course or group.")
        let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss an alert dialog")
        
        let accessDenied = UIAlertController(title: title, message: message, preferredStyle: .alert)
        accessDenied.addAction(UIAlertAction(title: dismiss, style: .cancel, handler: nil))
        present(accessDenied, animated: true, completion: nil)
    }
}

