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

class FileUploadAction: NSObject, UploadAction {
    let title = "" // ignored for file upload action
    let icon = UIImage() // ignored
    
    let otherActions: [UploadAction]
    let currentUpload: NewUpload
    let allowedUploadUTIs: [String]
    
    weak var viewController: UIViewController?
    let presentFromBarButtonItem: UIBarButtonItem?
    weak var delegate: UploadActionDelegate?
    
    init(otherActions: [UploadAction], currentUpload: NewUpload, allowedUploadUTIs: [String], viewController: UIViewController?, presentFromBarButtonItem: UIBarButtonItem?, delegate: UploadActionDelegate) {
        self.otherActions = otherActions
        self.viewController = viewController
        self.delegate = delegate
        self.allowedUploadUTIs = allowedUploadUTIs
        self.currentUpload = currentUpload
        self.presentFromBarButtonItem = presentFromBarButtonItem
    }
    
    func initiate() {
        let docsMenu = UIDocumentMenuViewController(documentTypes: allowedUploadUTIs, in: .import)
        docsMenu.delegate = self
        
        for action in otherActions.reversed() {
            docsMenu.addOption(withTitle: action.title, image: action.icon, order: UIDocumentMenuOrder.first, handler: action.initiate)
        }
        
        if let popover = docsMenu.popoverPresentationController, let presentFromBarButtonItem = presentFromBarButtonItem {
            popover.barButtonItem = presentFromBarButtonItem
        }
        
        viewController?.present(docsMenu, animated: true, completion: nil)
    }
}

// MARK: UIDocumentMenuDelegate

extension FileUploadAction: UIDocumentMenuDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        
        viewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        delegate?.actionCancelled()
    }
}

// MARK: UIDocumentPickerDelegate

extension FileUploadAction: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        delegate?.chooseUpload(.fileUpload([.fileURL(url)]))
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.actionCancelled()
    }
}
