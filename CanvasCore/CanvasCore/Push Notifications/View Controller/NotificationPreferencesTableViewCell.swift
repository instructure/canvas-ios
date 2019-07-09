//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation


enum ChangeNotificationPreferenceResult {
    case success
    case error(NSError)
}

protocol ChangeNotificationPreferenceProtocol {
    func changeNotificationPreference(_ indexPath: IndexPath, value: Bool, completion: @escaping (_ value: Bool, _ result: ChangeNotificationPreferenceResult) -> ())
}

class NotificationPreferencesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationLabel: UILabel!
    
    var item: GroupItem?
    @objc var indexPath: IndexPath?

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

        isUserInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityHint = NSLocalizedString("Tap to toggle", bundle: .core, comment: "")
        accessibilityTraits.insert(.button)
        updateA11y()
    }
    
    override func prepareForReuse() {
        self.notificationLabel.text = ""
        self.notificationSwitch.isOn = false
        accessibilityTraits = []
        accessibilityLabel = nil
    }

    func updateA11y() {
        if let item = item {
            let state = notificationSwitch.isOn ? NSLocalizedString("On", bundle: .core, comment: "") : NSLocalizedString("Off", bundle: .core, comment: "")
            accessibilityLabel = "\(item.name), \(state)"
        } else {
            accessibilityLabel = nil
        }
    }
    
    @IBAction func changeNotificationPreference(_ sender: AnyObject) {
        // Update value wherever necessary
        protocolHandler?.changeNotificationPreference(indexPath!, value: self.notificationSwitch.isOn) { value, result in DispatchQueue.main.async {
            switch result {
            case .success:
                // Nothing to do in the success case
                print("Successfully changed push notification preference")
            case .error(_):
                // In the error case switch the value back to what it was
                self.notificationSwitch.isOn = !value
            }
            self.updateA11y()
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }}
    }
}
