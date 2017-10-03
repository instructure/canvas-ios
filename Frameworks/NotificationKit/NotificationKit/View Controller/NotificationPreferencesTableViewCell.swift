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


enum ChangeNotificationPreferenceResult {
    case success()
    case error(NSError)
}

protocol ChangeNotificationPreferenceProtocol {
    func changeNotificationPreference(_ indexPath: IndexPath, value: Bool, completion: @escaping (_ value: Bool, _ result: ChangeNotificationPreferenceResult) -> ())
}

class NotificationPreferencesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationLabel: UILabel!
    
    var item: GroupItem?
    var indexPath: IndexPath?

    var protocolHandler: ChangeNotificationPreferenceProtocol?
    
    func setupCellFor<T>(_ item: GroupItem, indexPath: IndexPath, protocolHandler: T) where T:ChangeNotificationPreferenceProtocol {
        self.item = item
        self.indexPath = indexPath
        self.protocolHandler = protocolHandler
        
        // for now we're assuming that all of the preferences are the same
        // that's how were' setting them when we first set it up
        // Also if it's not set to immediately then we're setting it to never
        self.notificationSwitch.isOn = item.items.first?.frequency == NotificationPreference.Frequency.Immediately
        self.notificationLabel.text = item.name
        self.notificationLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    override func prepareForReuse() {
        self.notificationLabel.text = ""
        self.notificationSwitch.isOn = false
    }
    
    @IBAction func changeNotificationPreference(_ sender: AnyObject) {
        // Update value wherever necessary
        protocolHandler?.changeNotificationPreference(indexPath!, value: self.notificationSwitch.isOn, completion: { (value, result) -> () in
            switch result {
            case .success:
                // Nothing to do in the success case
                print("Successfully changed push notification preference")
            case .error(_):
                // In the error case switch the value back to what it was
                self.notificationSwitch.isOn = !value
            }
        })
        
    }
}
