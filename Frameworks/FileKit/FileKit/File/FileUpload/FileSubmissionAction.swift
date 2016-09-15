//
//  FileUploadAction.swift
//  File
//
//  Created by Derrick Hathaway on 12/3/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
        let docsMenu = UIDocumentMenuViewController(documentTypes: allowedUploadUTIs, inMode: .Import)
        docsMenu.delegate = self
        
        for action in otherActions.reverse() {
            docsMenu.addOptionWithTitle(action.title, image: action.icon, order: UIDocumentMenuOrder.First, handler: action.initiate)
        }
        
        if let popover = docsMenu.popoverPresentationController, presentFromBarButtonItem = presentFromBarButtonItem {
            popover.barButtonItem = presentFromBarButtonItem
        }
        
        viewController?.presentViewController(docsMenu, animated: true, completion: nil)
    }
}

// MARK: UIDocumentMenuDelegate

extension FileUploadAction: UIDocumentMenuDelegate {
    func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        
        viewController?.presentViewController(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
        delegate?.actionCancelled()
    }
}

// MARK: UIDocumentPickerDelegate

extension FileUploadAction: UIDocumentPickerDelegate {
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        delegate?.chooseUpload(.FileUpload([.FileURL(url)]))
    }
    
    func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController) {
        delegate?.actionCancelled()
    }
}
