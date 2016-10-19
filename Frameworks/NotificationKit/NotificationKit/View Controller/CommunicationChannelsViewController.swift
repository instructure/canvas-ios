//
//  CommunicationChannelsViewController.swift
//  NotificationKit
//
//  Created by Miles Wright on 7/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation


// MARK: Class Instantiation
extension CommunicationChannelsViewController {
    private static let storyboardName = "Main"
    private static let viewControllerName = "CommunicationsChannelsViewController"
    public class func new(dataController: NotificationKitController) -> CommunicationChannelsViewController {
        let storyboard = UIStoryboard(name: CommunicationChannelsViewController.storyboardName, bundle: NSBundle(forClass: CommunicationChannelsViewController.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier(CommunicationChannelsViewController.viewControllerName) as! CommunicationChannelsViewController
        
        controller.dataController = dataController
        
        return controller
    }
}

public class CommunicationChannelsViewController: UITableViewController {
    private var dataController: NotificationKitController!
    private var datasource: [CommunicationChannel] = []
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Notification Preferences", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Title for the notification preferences page")
        
        tableView.tableFooterView = UIView(frame: CGRectZero)

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(CommunicationChannelsViewController.refreshDataSource(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl!.beginRefreshing()
        self.refreshDataSource(refreshControl!)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.backBarButtonItem?.title = ""
    }
    
    func refreshDataSource(sender: AnyObject) {
        self.dataController.getCommunicationChannels { (result) -> () in
            if result.error != nil {
                self.datasource = []

                let title = NSLocalizedString("No Communication Channels Found", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Alert title when unable to load communication channels")
                let message = NSLocalizedString("Unable to load any Communication Channels at this time.  Error: \(result.error?.localizedDescription)", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Alert message when unable to load communication channels")
                let actionText = NSLocalizedString("OK", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "OK Button Title")
                
                self.showSimpleAlert(title, message: message, actionText: actionText)
                
            } else if result.value != nil {
                if let newDatasource = result.value {
                    self.datasource = newDatasource
                    self.tableView.reloadData()
                } else {
                    
                    let title = NSLocalizedString("Can't Display Communication Channels", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Alert title when unable to parse JSON for communication channels")
                    let message = NSLocalizedString("Unable to display any Communication Channels returned from the server at this time.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Alert message when unable to parse JSON for communication channels")
                    let actionText = NSLocalizedString("OK", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "OK Button Title")
                    
                    self.showSimpleAlert(title, message: message, actionText: actionText)
                }
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
}

extension CommunicationChannelsViewController {
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    private static let cellReuseIdentifier = "CommunicationChannelCell"
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CommunicationChannelsViewController.cellReuseIdentifier, forIndexPath: indexPath) 
        let communicationChannel = datasource[indexPath.row] as CommunicationChannel
        cell.textLabel?.text = communicationChannel.address
        cell.detailTextLabel?.text = communicationChannel.type.description
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = datasource[indexPath.row] as CommunicationChannel
        let viewController = NotificationPreferencesViewController.new(channel, dataController: self.dataController)
        
        navigationController?.pushViewController(viewController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

