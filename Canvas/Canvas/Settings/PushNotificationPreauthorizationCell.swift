//
//  PushNotificationPreauthorizationCell.swift
//  iCanvas
//
//  Created by Miles Wright on 8/7/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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