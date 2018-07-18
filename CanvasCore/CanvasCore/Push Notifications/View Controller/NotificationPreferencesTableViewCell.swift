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
