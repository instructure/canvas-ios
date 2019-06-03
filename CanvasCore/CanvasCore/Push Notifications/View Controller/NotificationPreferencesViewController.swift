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

open class NotificationPreferencesViewController: UITableViewController {
    var channel: CommunicationChannel!
    var dataController: NotificationKitController!
    fileprivate var datasource: [(displayGroup: DisplayGroup, groupItems: [GroupItem]?)] = []
    
    fileprivate static let storyboardName = "Main"
    fileprivate static let viewControllerName = "NotificationPreferencesViewController"
    open class func new(_ channel: CommunicationChannel, dataController: NotificationKitController) -> NotificationPreferencesViewController {
        let storyboard = UIStoryboard(name: NotificationPreferencesViewController.storyboardName, bundle: Bundle(for: NotificationPreferencesViewController.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: NotificationPreferencesViewController.viewControllerName) as! NotificationPreferencesViewController
        
        controller.channel = channel
        controller.dataController = dataController
        
        return controller
    }
    
    // Don't allow people to create using init, would be great to prevent other ways in
    fileprivate override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(NotificationPreferencesViewController.refreshDataSource(_:)), for: UIControl.Event.valueChanged)
        
        refreshControl!.beginRefreshing()
        self.refreshDataSource(refreshControl!)
    }
    
    @objc func refreshDataSource(_ sender: AnyObject) {
        self.dataController.getNotificationPreferences(channel, completion: { (result) -> () in
            
            if let error = result.error {
                
                let title = NSLocalizedString("Could not load notification preferences", tableName: "Localizable", bundle: .core, value: "", comment: "Alert title when unable to load notification preferences")
                
                let template = NSLocalizedString("Unable to load any notification preferences at this time.  Error: %@", tableName: "Localizable", bundle: .core, value: "", comment: "Alert message when unable to load notification preferences")
                let message = String.localizedStringWithFormat(template, error.localizedDescription)
                
                let actionText = NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: "OK Button Title")
                
                self.showSimpleAlert(title, message: message, actionText: actionText)

                return
            }
            
            if let preferences = result.value {
                self.channel.createNotificationPreferencesGroups(preferences)
                self.datasource = self.channel.preferencesDataSource
                
                self.tableView.reloadData()
            } else {
                let title = NSLocalizedString("Can't Display Notification Preferences", tableName: "Localizable", bundle: .core, value: "", comment: "Alert title when unable to parse JSON for notification preferences")
                let message = NSLocalizedString("Unable to display any notification preferences returned from the server at this time.", tableName: "Localizable", bundle: .core, value: "", comment: "Alert message when unable to parse JSON for notification preferences")
                let actionText = NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: "OK Button Title")
                
                self.showSimpleAlert(title, message: message, actionText: actionText)
            }
            
            self.refreshControl?.endRefreshing()
        })
    }
}

extension NotificationPreferencesViewController {
    
    // MARK: UITableView Datasource methods
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = datasource[section].groupItems {
            return items.count
        } else {
            return 0
        }
    }
    
    fileprivate static let cellReuseIdentifier = "NotificationPreferencesTableViewCell"
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationPreferencesViewController.cellReuseIdentifier, for: indexPath) as! NotificationPreferencesTableViewCell
        
        if let groupItems = datasource[indexPath.section].groupItems {
            let groupItem = groupItems[indexPath.row]
            cell.setupCellFor(groupItem, indexPath: indexPath, protocolHandler: self)
        } else {
            // Couldn't get groupItems from the datasource...
            // What should be done in this case? no idea
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = datasource[section]
        return item.displayGroup.rawValue
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? NotificationPreferencesTableViewCell else { return }
        cell.notificationSwitch.isOn = !cell.notificationSwitch.isOn
        cell.changeNotificationPreference(cell)
    }
}

extension NotificationPreferencesViewController: ChangeNotificationPreferenceProtocol {
    func changeNotificationPreference(_ indexPath: IndexPath, value: Bool, completion: @escaping (_ value: Bool, _ result: ChangeNotificationPreferenceResult) -> ()) {
        
        let groupItems = datasource[indexPath.section].groupItems!
        let item = groupItems[indexPath.row]

        for item in item.items {
            item.frequency = item.frequency.opposite
        }
        
        dataController.setNotificationPreferences(channel, preferences: item.items) { [weak self] (setPreferenceResult) -> () in
            if setPreferenceResult.error != nil {
                for item in item.items { // revert back to what it was prior
                    item.frequency = item.frequency.opposite
                }
                self?.showCouldNotUpdatePushNotificationAlert()
                completion(value, .error(setPreferenceResult.error!))
            } else if setPreferenceResult.value != nil {
                completion(value, .success)
            }
        }
    }
    
    @objc func showCouldNotUpdatePushNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Could not update", comment: "Error title for being unable to update a push notification preference"), message: NSLocalizedString("We were not able to update this value with the server", tableName: "Localizable", bundle: .core, value: "", comment: "Error message for being unable to update a push notification preference"), preferredStyle: UIAlertController.Style.alert)
        
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: "OK Button Title"), style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

