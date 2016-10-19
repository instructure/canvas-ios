//
//  AnythingButFilesSubmissionAction.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/4/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit


class AnythingButFilesUploadAction: UploadAction {
    let title = "" // Ignored
    let icon = UIImage() // Ignored
    
    let actions: [UploadAction]
    weak var viewController: UIViewController?
    let barButtonItem: UIBarButtonItem?
    weak var delegate: UploadActionDelegate?
    
    init(actions: [UploadAction], viewController: UIViewController?, barButtonItem: UIBarButtonItem?, delegate: UploadActionDelegate) {
        self.actions = actions
        self.barButtonItem = barButtonItem
    }
    
    func initiate() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("What would you like to turn in?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "prompt for submission upload"), preferredStyle: .ActionSheet)
        
        for action in actions {
            alertController.addAction(UIAlertAction(title: action.title, style: .Default, handler: { _ in action.initiate() }))
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Cancel button title"), style: .Cancel, handler: { _ in
            self.delegate?.actionCancelled()
        }))
        
        if let popover = alertController.popoverPresentationController, barButtonItem = barButtonItem {
            popover.barButtonItem = barButtonItem
        }
        
        viewController?.presentViewController(alertController, animated: true, completion: nil)
    }
}

