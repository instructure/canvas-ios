//
//  NotificationPreferencesViewController.swift
//  NotificationKit
//
//  Created by Miles Wright on 5/15/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public class NotificationPreferencesViewController: UITableViewController {
    var channel: CommunicationChannel!
    var dataController: NotificationKitController!
    private var datasource: [(displayGroup: DisplayGroup, groupItems: [GroupItem]?)] = []
    
    private static let storyboardName = "Main"
    private static let viewControllerName = "NotificationPreferencesViewController"
    public class func new(channel: CommunicationChannel, dataController: NotificationKitController) -> NotificationPreferencesViewController {
        let storyboard = UIStoryboard(name: NotificationPreferencesViewController.storyboardName, bundle: NSBundle(forClass: NotificationPreferencesViewController.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier(NotificationPreferencesViewController.viewControllerName) as! NotificationPreferencesViewController
        
        controller.channel = channel
        controller.dataController = dataController
        
        return controller
    }
    
    // Don't allow people to create using init, would be great to prevent other ways in
    private override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshDataSource:"), forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl!.beginRefreshing()
        self.refreshDataSource(refreshControl!)
    }
    
    func refreshDataSource(sender: AnyObject) {
        self.dataController.getNotificationPreferences(channel, completion: { (result) -> () in
            
            if let _ = result.error {
                
                let title = NSLocalizedString("Could not load notification preferences", comment: "Alert title when unable to load notification preferences")
                let message = NSLocalizedString("Unable to load any notification preferences at this time.  Error: \(result.error?.localizedDescription)", comment: "Alert message when unable to load notification preferences")
                let actionText = NSLocalizedString("Ok", comment: "Alert action button text when unable to load notification preferences")
                
                self.showSimpleAlert(title, message: message, actionText: actionText)

                return
            }
            
            if let preferences = result.value {
                self.channel.createNotificationPreferencesGroups(preferences)
                self.datasource = self.channel.preferencesDataSource
                
                self.tableView.reloadData()
            } else {
                let title = NSLocalizedString("Can't Display Notification Preferences", comment: "Alert title when unable to parse JSON for notification preferences")
                let message = NSLocalizedString("Unable to display any notification preferences returned from the server at this time.", comment: "Alert message when unable to parse JSON for notification preferences")
                let actionText = NSLocalizedString("Ok", comment: "Alert action button text when unable to parse JSON for notification preferences")
                
                self.showSimpleAlert(title, message: message, actionText: actionText)
            }
            
            self.refreshControl?.endRefreshing()
        })
    }
}

extension NotificationPreferencesViewController {
    
    // MARK: UITableView Datasource methods
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datasource.count
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = datasource[section].groupItems {
            return items.count
        } else {
            return 0
        }
    }
    
    private static let cellReuseIdentifier = "NotificationPreferencesTableViewCell"
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NotificationPreferencesViewController.cellReuseIdentifier, forIndexPath: indexPath) as! NotificationPreferencesTableViewCell
        
        if let groupItems = datasource[indexPath.section].groupItems {
            let groupItem = groupItems[indexPath.row]
            cell.setupCellFor(groupItem, indexPath: indexPath, protocolHandler: self)
        } else {
            // Couldn't get groupItems from the datasource...
            // What should be done in this case? no idea
        }
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = datasource[section]
        return item.displayGroup.rawValue
    }
}

extension NotificationPreferencesViewController: ChangeNotificationPreferenceProtocol {
    func changeNotificationPreference(indexPath: NSIndexPath, value: Bool, completion: (value: Bool, result: ChangeNotificationPreferenceResult) -> ()) {
        
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
                completion(value: value, result: ChangeNotificationPreferenceResult.Error(setPreferenceResult.error!))
            } else if setPreferenceResult.value != nil {
                completion(value: value, result: ChangeNotificationPreferenceResult.Success())
            }
        }
    }
    
    func showCouldNotUpdatePushNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Could not update", comment: "Error title for being unable to update a push notification preference"), message: NSLocalizedString("We were not able to update this value with the server", comment: "Error message for being unable to update a push notification preference"), preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Action title for being unable to update a push notification preference"), style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

