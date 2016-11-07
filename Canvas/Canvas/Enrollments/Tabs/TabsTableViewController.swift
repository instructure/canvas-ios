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
import EnrollmentKit
import TooLegit
import SoPretty
import SoPersistent
import ReactiveCocoa
import SoLazy
import TechDebt

extension Tab {
    func routingURL(session: Session) -> NSURL? {
        if isPages {
            let path = contextID.apiPath + "/pages_home"
            return NSURL(string: path)
        }
        if isHome {
            guard let enrollment = session.enrollmentsDataSource[contextID] else { return url }
            return NSURL(string: enrollment.defaultViewPath)
        }
        return url
    }
}

extension ColorfulViewModel {
    init(session: Session, tab: Tab) {
        self.init(style: .Basic)
        
        title.value = tab.label
        icon.value = tab.icon
        color <~ session.enrollmentsDataSource.producer(tab.contextID)
            .map { $0?.color ?? .prettyGray() }
    }
}

class TabsTableViewController: Tab.TableViewController {
    
    let route: (UIViewController, NSURL)->()
    let session: Session
    let contextID: ContextID
    
    var alreadyRoutedToTheHomeTab = false
    
    init(session: Session, contextID: ContextID, route: (UIViewController, NSURL)->()) throws {
        self.session = session
        self.route = route
        self.contextID = contextID
        super.init()
        
        prepare(try Tab.collection(session, contextID: contextID), refresher: try Tab.refresher(session, contextID: contextID)) { tab in ColorfulViewModel(session: session, tab: tab) }
        
        rac_title <~ session.enrollmentsDataSource.producer(contextID).map { $0?.name }
        
        cbi_canBecomeMaster = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let routingURL = collection[indexPath].routingURL(session) {
            route(self, routingURL)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !alreadyRoutedToTheHomeTab
            && UIDevice.currentDevice().userInterfaceIdiom == .Pad
            && tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
            if let routingURL = collection.filter({ $0.isHome }).first?.routingURL(session) {
                route(self, routingURL)
            }
            alreadyRoutedToTheHomeTab = true
        }
    }
    
    override func handleError(error: NSError) {
        guard error.code == 401 else { super.handleError(error); return }
        
        let title = NSLocalizedString("Access Denied", comment: "Access Denied from the server")
        let message = NSLocalizedString("You do not have access to this content. The Course or Group may not have started, or may have been concluded.", comment: "Error message for an unauthorized course or group.")
        let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss an alert dialog")
        
        let accessDenied = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        accessDenied.addAction(UIAlertAction(title: dismiss, style: .Cancel, handler: nil))
        presentViewController(accessDenied, animated: true, completion: nil)
    }
}

