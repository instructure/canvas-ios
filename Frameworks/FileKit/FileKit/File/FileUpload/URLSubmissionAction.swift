//
//  URLSubmissionAction.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import SoPretty


class URLSubmissionAction: UploadAction {
    let title = NSLocalizedString("Choose a Webpage", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "URL submission option")
    let icon = UIImage.FileKitImageNamed("icon_link")
    
    weak var viewController: UIViewController?
    weak var delegate: UploadActionDelegate?
    
    init(viewController: UIViewController?, delegate: UploadActionDelegate) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    func initiate() {
        guard let vc = viewController else { return print("There was no view controller to present from.") }
        
        let browser = BrowserViewController.presentFromViewController(vc)
        browser.didCancel = { [weak delegate] in
            delegate?.actionCancelled()
        }
        browser.didSelectURLForSubmission = { [weak delegate] url in
            delegate?.chooseUpload(.URL(url))
        }
    }
}