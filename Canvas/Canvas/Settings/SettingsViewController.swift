
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
    
    private var dataSource: [SettingsRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        dataSource = data()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: false)
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let settingsRow = dataSource[indexPath.row] as SettingsRow
        let cell = settingsRow.cellForSettingsRow(tableView, indexPath: indexPath)
        print(cell)
        print(cell.contentView)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let settingsRow = dataSource[indexPath.row] as SettingsRow
        settingsRow.action()
    }
}


// MARK: Settings Row Protocol
private protocol SettingsRow: class {
    var action: () -> () { get }
    func cellForSettingsRow(tableView: UITableView, indexPath: NSIndexPath)  -> UITableViewCell
}

// MARK: Settings Row Types
private class TextSettingsRow: SettingsRow {
    private var title: String
    private var action: () -> ()
    
    private static var identifier = "TextSettingsRow"
    
    init(title: String, action: () -> ()) {
        self.title = title
        self.action = action
    }
    
    private func cellForSettingsRow(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TextSettingsRow.identifier, forIndexPath: indexPath)
        cell.textLabel?.text = title
        return cell
    }
}

private class EnablePushSettingsRow: SettingsRow {
    private var action: () -> ()
    private var protocolHandler: PushNotificationPreauthorizationProtocol
    
    private static var identifier = "PushNotificationPreauthorizationCell"
    
    init(protocolHandler: PushNotificationPreauthorizationProtocol) {
        // This item has no bearing on this cell, these are handled inside of the cell setup instead, this could possibly be an indicator that this is the wrong way to go about this
        self.action = { }
        
        self.protocolHandler = protocolHandler
    }
    
    private func cellForSettingsRow(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(EnablePushSettingsRow.identifier, forIndexPath: indexPath) as! PushNotificationPreauthorizationCell
        cell.setupCell(self.protocolHandler)
        return cell
    }
}

private class SystemSettingsLinkSettingsRow: SettingsRow {
    private var action: () -> ()
    
    private static var identifier = "SystemSettingsLinkCell"
    
    init(action: () -> ()) {
        self.action = action
    }
    
    private func cellForSettingsRow(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SystemSettingsLinkSettingsRow.identifier, forIndexPath: indexPath) as! SystemSettingsLinkCell
        cell.setupCell()
        return cell
    }
}


// MARK: Datasource Generation
extension SettingsViewController {
    
    private func data() -> [SettingsRow] {
        let about = TextSettingsRow(title: NSLocalizedString("About", comment: "Settings entry title for About")) { () -> () in
            let aboutViewController = AboutViewController.init()
            aboutViewController.canvasAPI = self.canvasAPI
            self.navigationController?.pushViewController(aboutViewController, animated: true)
        }
        
        let landingPage = TextSettingsRow(title: NSLocalizedString("Landing Page", comment: "Settings entry title for Choosing a Landing Page"), action: {
            let currentUserID = CanvasKeymaster.theKeymaster().currentClient.currentUser.id
            
            let viewController = LandingPageViewController(currentUserID: currentUserID)
            self.navigationController?.pushViewController(viewController, animated: true)
        })
        
        let notificationPreferences = TextSettingsRow(title: NSLocalizedString("Notification Preferences", comment: "Settings entry title for Notification Preferences")) { () -> () in
            let session = CanvasKeymaster.theKeymaster().currentClient.authSession
            let notificationDataController = NotificationKitController(session: session)
            
            let viewController = CommunicationChannelsViewController.new(notificationDataController)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        var dataSource: [SettingsRow] = [about, landingPage, notificationPreferences]
        
        if PushPreAuthStatus.currentPushPreAuthStatus() == .ShownAndDeclined {
            let enablePush = EnablePushSettingsRow(protocolHandler: self)
            // TODO: I'd like to do something like this but compiler has issues
//            dataSource.insert(enablePush, atIndex: find(dataSource, notificationPreferences))
            dataSource.append(enablePush)
        } else if (UIApplication.sharedApplication().currentUserNotificationSettings()?.types.contains(.Alert) != nil) { // if the user declined the user notifications
            let systemSettingsLink = SystemSettingsLinkSettingsRow(action: { () -> () in
                // Open the settings app and take it to our app where they can turn on notifications
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) { // should always succeed
                    UIApplication.sharedApplication().openURL(url)
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
                for (index, element) in self.dataSource.enumerate() {
                    if element === enablePushSettingsRow {
                        switch result {
                        case true:
                            self.dataSource.removeAtIndex(index)
                            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        default:
                            if let _ = element as? EnablePushSettingsRow {
                                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
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
    private static let storyboardName = "Settings"
    private static let viewControllerName = "SettingsViewController"
    private static let tableViewCellName = "SettingsTableViewCell"
    
    class func controller(canvasAPI: CKCanvasAPI) -> SettingsViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: SettingsViewController.self))
        let viewController = storyboard.instantiateViewControllerWithIdentifier(viewControllerName) as! SettingsViewController
        viewController.canvasAPI = canvasAPI
        return viewController
    }
}
