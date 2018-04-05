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

import Foundation
import UIKit
import CanvasCore
import CanvasKit1
import TechDebt
import CanvasKeymaster
import UserNotifications

class SettingsViewController: UIViewController, PageViewEventViewControllerLoggingProtocol {
    @IBOutlet weak var tableView: UITableView!
    
    var canvasAPI: CKCanvasAPI?
    
    fileprivate var dataSource: [SettingsRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight  = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        dataSource = data()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.modalPresentationStyle = .formSheet
    }
    
    func done() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
        startTrackingTimeOnViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/profile/settings")
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsRow = dataSource[indexPath.row] as SettingsRow
        let cell = settingsRow.cellForSettingsRow(tableView, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let settingsRow = dataSource[indexPath.row] as SettingsRow
        settingsRow.action()
    }
}


// MARK: Settings Row Protocol
protocol SettingsRow: class {
    var action: () -> () { get }
    func cellForSettingsRow(_ tableView: UITableView, indexPath: IndexPath)  -> UITableViewCell
}

// MARK: Settings Row Types
class TextSettingsRow: SettingsRow {
    var title: String
    var action: () -> ()
    
    static var identifier = "TextSettingsRow"
    
    init(title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }
    
    func cellForSettingsRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextSettingsRow.identifier, for: indexPath)
        cell.textLabel?.text = title
        return cell
    }
}

// MARK: Datasource Generation
extension SettingsViewController {
    
    fileprivate func data() -> [SettingsRow] {
        let profile = TextSettingsRow(title: NSLocalizedString("Profile", comment: "")) { () -> () in
            if let session = CanvasKeymaster.the().currentClient?.authSession {
                self.navigationController?.pushViewController(profileController(session), animated: true)
            }
        }

        let about = TextSettingsRow(title: NSLocalizedString("About", comment: "Settings entry title for About")) { () -> () in
            let aboutViewController = AboutViewController.init()
            aboutViewController.canvasAPI = self.canvasAPI
            self.navigationController?.pushViewController(aboutViewController, animated: true)
        }
        
        let landingPage = TextSettingsRow(title: NSLocalizedString("Landing Page", comment: "Settings entry title for Choosing a Landing Page"), action: {
            let currentUserID = CanvasKeymaster.the().currentClient?.currentUser.id
            
            let viewController = LandingPageViewController(currentUserID: currentUserID!)
            self.navigationController?.pushViewController(viewController, animated: true)
        })
        
        let notificationPreferences = TextSettingsRow(title: NSLocalizedString("Notification Preferences", comment: "Settings entry title for Notification Preferences")) { () -> () in
            if let session = CanvasKeymaster.the().currentClient?.authSession {
                let notificationDataController = NotificationKitController(session: session)
                
                let viewController = CommunicationChannelsViewController.new(notificationDataController)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        let dataSource: [SettingsRow] = [profile, about, landingPage, notificationPreferences]
        return dataSource
    }
}

// MARK: Instantiation
extension SettingsViewController {
    fileprivate static let storyboardName = "Settings"
    fileprivate static let viewControllerName = "SettingsViewController"
    fileprivate static let tableViewCellName = "SettingsTableViewCell"
    
    class func controller(_ canvasAPI: CKCanvasAPI) -> SettingsViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: SettingsViewController.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName) as! SettingsViewController
        viewController.canvasAPI = canvasAPI
        return viewController
    }
}
