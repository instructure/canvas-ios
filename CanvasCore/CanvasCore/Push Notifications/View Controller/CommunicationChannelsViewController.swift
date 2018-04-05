//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation


// MARK: Class Instantiation
extension CommunicationChannelsViewController {
    fileprivate static let storyboardName = "Main"
    fileprivate static let viewControllerName = "CommunicationsChannelsViewController"
    public class func new(_ dataController: NotificationKitController) -> CommunicationChannelsViewController {
        let storyboard = UIStoryboard(name: CommunicationChannelsViewController.storyboardName, bundle: Bundle(for: CommunicationChannelsViewController.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: CommunicationChannelsViewController.viewControllerName) as! CommunicationChannelsViewController
        
        controller.dataController = dataController
        
        return controller
    }
}

open class CommunicationChannelsViewController: UITableViewController, PageViewEventViewControllerLoggingProtocol {
    fileprivate var dataController: NotificationKitController!
    fileprivate var datasource: [CommunicationChannel] = []

    var notificationsEnabled: Bool?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Notification Preferences", tableName: "Localizable", bundle: .core, value: "", comment: "Title for the notification preferences page")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(CommunicationChannelsViewController.refreshDataSource(_:)), for: UIControlEvents.valueChanged)
        
        refreshControl!.beginRefreshing()
        self.refreshDataSource(refreshControl!)

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    func appDidBecomeActive() {
        refreshNotificationSettings()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.backBarButtonItem?.title = ""
        refreshNotificationSettings()
        startTrackingTimeOnViewController()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/profile/communication")
    }

    func refreshNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings() { [weak self] settings in
            self?.notificationsEnabled = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func refreshDataSource(_ sender: AnyObject) {
        self.dataController.getCommunicationChannels { (result) -> () in
            DispatchQueue.main.async {
                if result.error != nil {
                    self.datasource = []

                    let title = NSLocalizedString("No Communication Channels Found", tableName: "Localizable", bundle: .core, value: "", comment: "Alert title when unable to load communication channels")
                    let message = NSLocalizedString("Unable to load any Communication Channels at this time.", tableName: "Localizable", bundle: .core, value: "", comment: "Alert message when unable to load communication channels")
                    let actionText = NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: "OK Button Title")

                    self.showSimpleAlert(title, message: message, actionText: actionText)

                } else if result.value != nil {
                    if let newDatasource = result.value {
                        self.datasource = newDatasource
                        self.tableView.reloadData()
                    } else {

                        let title = NSLocalizedString("Can't Display Communication Channels", tableName: "Localizable", bundle: .core, value: "", comment: "Alert title when unable to parse JSON for communication channels")
                        let message = NSLocalizedString("Unable to display any Communication Channels returned from the server at this time.", tableName: "Localizable", bundle: .core, value: "", comment: "Alert message when unable to parse JSON for communication channels")
                        let actionText = NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: "OK Button Title")

                        self.showSimpleAlert(title, message: message, actionText: actionText)
                    }
                }

                self.refreshControl?.endRefreshing()
            }
        }
    }
}

extension CommunicationChannelsViewController {
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.datasource.count
    }
    
    fileprivate static let cellReuseIdentifier = "CommunicationChannelCell"
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("Allow Notifications in Settings", comment: "")
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: CommunicationChannelsViewController.cellReuseIdentifier, for: indexPath) 
        let communicationChannel = datasource[indexPath.row] as CommunicationChannel
        cell.textLabel?.text = communicationChannel.address
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.text = communicationChannel.type.description
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url)
            }
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        let channel = datasource[indexPath.row] as CommunicationChannel
        let viewController = NotificationPreferencesViewController.new(channel, dataController: self.dataController)
        
        navigationController?.pushViewController(viewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else { return nil }
        guard let notificationsEnabled = notificationsEnabled else {
            return nil
        }
        return notificationsEnabled
            ? NSLocalizedString("All notifications are currently enabled.", comment: "")
            : NSLocalizedString("All notifications are currently disabled.", comment: "")
    }
}

