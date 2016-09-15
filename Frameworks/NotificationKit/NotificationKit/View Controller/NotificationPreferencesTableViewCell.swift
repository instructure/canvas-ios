//
//  NotificationPreferencesTableViewCell.swift
//  iCanvas
//
//  Created by Miles Wright on 7/16/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation


enum ChangeNotificationPreferenceResult {
    case Success()
    case Error(NSError)
}

protocol ChangeNotificationPreferenceProtocol {
    func changeNotificationPreference(indexPath: NSIndexPath, value: Bool, completion: (value: Bool, result: ChangeNotificationPreferenceResult) -> ())
}

class NotificationPreferencesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationLabel: UILabel!
    
    var item: GroupItem?
    var indexPath: NSIndexPath?

    var protocolHandler: ChangeNotificationPreferenceProtocol?
    
    func setupCellFor<T where T:ChangeNotificationPreferenceProtocol>(item: GroupItem, indexPath: NSIndexPath, protocolHandler: T) {
        self.item = item
        self.indexPath = indexPath
        self.protocolHandler = protocolHandler
        
        // for now we're assuming that all of the preferences are the same
        // that's how were' setting them when we first set it up
        // Also if it's not set to immediately then we're setting it to never
        self.notificationSwitch.on = item.items.first?.frequency == NotificationPreference.Frequency.Immediately
        self.notificationLabel.text = item.name
    }
    
    override func prepareForReuse() {
        self.notificationLabel.text = ""
        self.notificationSwitch.on = false
    }
    
    @IBAction func changeNotificationPreference(sender: AnyObject) {
        // Update value wherever necessary
        protocolHandler?.changeNotificationPreference(indexPath!, value: self.notificationSwitch.on, completion: { (value, result) -> () in
            switch result {
            case .Success:
                // Nothing to do in the success case
                print("Successfully changed push notification preference")
            case .Error(_):
                // In the error case switch the value back to what it was
                self.notificationSwitch.on = !value
            }
        })
        
    }
}