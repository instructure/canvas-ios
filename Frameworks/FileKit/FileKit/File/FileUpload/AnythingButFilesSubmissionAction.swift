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

