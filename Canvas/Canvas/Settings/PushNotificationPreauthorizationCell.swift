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
import NotificationKit


protocol PushNotificationPreauthorizationProtocol {
    func showPreauthorizationPrompt()
}

class PushNotificationPreauthorizationCell : UITableViewCell {

    var protocolHandler: PushNotificationPreauthorizationProtocol?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var preauthorizationSwitch: UISwitch!
    
    @IBAction func togglePreauthorizationSwitch(sender: AnyObject) {
        protocolHandler?.showPreauthorizationPrompt()
    }
    
    func setupCell(protocolHandler: PushNotificationPreauthorizationProtocol) {
        self.label.text = NSLocalizedString("Enable Push Notifications", comment: "Prompt asking user to enable push notifications")
        
        // This cell is only shown in the case of the user have a value of PushState.DeclinedPreauthorizationPrompt and the whole purpose is to provide an opportunity for the user to reconsider and turn push on
        self.preauthorizationSwitch.on = false
        
        self.protocolHandler = protocolHandler
    }
}