
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