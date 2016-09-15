//
//  SimpleAlertExtension.swift
//  iCanvas
//
//  Created by Miles Wright on 7/30/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

extension UIViewController {
    func showSimpleAlert(title: String, message: String, actionText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let alertAction = UIAlertAction(title: actionText, style: .Default, handler: nil)
        
        alert.addAction(alertAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}