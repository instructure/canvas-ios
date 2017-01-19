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
import NotificationKit
import TooLegit
import CanvasKit1
import TechDebt
import CanvasKeymaster

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var canvasAPI: CKCanvasAPI?
    
    fileprivate var dataSource: [SettingsRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        dataSource = data()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
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
        print(cell)
        print(cell.contentView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsRow = dataSource[indexPath.row] as SettingsRow
        settingsRow.action()
    }
}


// MARK: Settings Row Protocol
private protocol SettingsRow: class {
    var action: () -> () { get }
    func cellForSettingsRow(_ tableView: UITableView, indexPath: IndexPath)  -> UITableViewCell
}

// MARK: Settings Row Types
private class TextSettingsRow: SettingsRow {
    fileprivate var title: String
    fileprivate var action: () -> ()
    
    fileprivate static var identifier = "TextSettingsRow"
    
    init(title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }
    
    fileprivate func cellForSettingsRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextSettingsRow.identifier, for: indexPath)
        cell.textLabel?.text = title
        return cell
    }
}

private class EnablePushSettingsRow: SettingsRow {
    fileprivate var action: () -> ()
    fileprivate var protocolHandler: PushNotificationPreauthorizationProtocol
    
    fileprivate static var identifier = "PushNotificationPreauthorizationCell"
    
    init(protocolHandler: PushNotificationPreauthorizationProtocol) {
        // This item has no bearing on this cell, these are handled inside of the cell setup instead, this could possibly be an indicator that this is the wrong way to go about this
        self.action = { }
        
        self.protocolHandler = protocolHandler
    }
    
    fileprivate func cellForSettingsRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnablePushSettingsRow.identifier, for: indexPath) as! PushNotificationPreauthorizationCell
        cell.setupCell(self.protocolHandler)
        return cell
    }
}

private class SystemSettingsLinkSettingsRow: SettingsRow {
    fileprivate var action: () -> ()
    
    fileprivate static var identifier = "SystemSettingsLinkCell"
    
    init(action: @escaping () -> ()) {
        self.action = action
    }
    
    fileprivate func cellForSettingsRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SystemSettingsLinkSettingsRow.identifier, for: indexPath) as! SystemSettingsLinkCell
        cell.setupCell()
        return cell
    }
}


// MARK: Datasource Generation
extension SettingsViewController {
    
    fileprivate func data() -> [SettingsRow] {
        let about = TextSettingsRow(title: NSLocalizedString("About", comment: "Settings entry title for About")) { () -> () in
            let aboutViewController = AboutViewController.init()
            aboutViewController.canvasAPI = self.canvasAPI
            self.navigationController?.pushViewController(aboutViewController, animated: true)
        }
        
        let landingPage = TextSettingsRow(title: NSLocalizedString("Landing Page", comment: "Settings entry title for Choosing a Landing Page"), action: {
            let currentUserID = CanvasKeymaster.the().currentClient.currentUser.id
            
            let viewController = LandingPageViewController(currentUserID: currentUserID!)
            self.navigationController?.pushViewController(viewController, animated: true)
        })
        
        let notificationPreferences = TextSettingsRow(title: NSLocalizedString("Notification Preferences", comment: "Settings entry title for Notification Preferences")) { () -> () in
            let session = CanvasKeymaster.the().currentClient.authSession
            let notificationDataController = NotificationKitController(session: session)
            
            let viewController = CommunicationChannelsViewController.new(notificationDataController)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        var dataSource: [SettingsRow] = [about, landingPage, notificationPreferences]
        
        if PushPreAuthStatus.currentPushPreAuthStatus() == .shownAndDeclined {
            let enablePush = EnablePushSettingsRow(protocolHandler: self)
            // TODO: I'd like to do something like this but compiler has issues
//            dataSource.insert(enablePush, atIndex: find(dataSource, notificationPreferences))
            dataSource.append(enablePush)
        } else if (UIApplication.shared.currentUserNotificationSettings?.types.contains(.alert) != nil) { // if the user declined the user notifications
            let systemSettingsLink = SystemSettingsLinkSettingsRow(action: { () -> () in
                // Open the settings app and take it to our app where they can turn on notifications
                if let url = URL(string: UIApplicationOpenSettingsURLString) { // should always succeed
                    UIApplication.shared.openURL(url)
                }
            })
            dataSource.append(systemSettingsLink)
        }
        
        return dataSource
    }
}

// MARK: PushNotificationPreauthorizationProtocol 
extension SettingsViewController: PushNotificationPreauthorizationProtocol {
    func showPreauthorizationPrompt() {
        NotificationKitController.showPreauthorizationAlert(self, completion: { (result) -> () in
            if let enablePushSettingsRow = self.dataSource.filter({ $0 is EnablePushSettingsRow }).first {
                for (index, element) in self.dataSource.enumerated() {
                    if element === enablePushSettingsRow {
                        switch result {
                        case true:
                            self.dataSource.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                        default:
                            if let _ = element as? EnablePushSettingsRow {
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                            }
                        }
                    }
                }
            }
            
        })
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
