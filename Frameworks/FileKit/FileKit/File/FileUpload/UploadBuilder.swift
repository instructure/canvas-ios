
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
    
    

import Foundation
import MobileCoreServices
import Photos
//import MediaKit
import SoPretty
import MobileCoreServices

// 😁
public class UploadBuilder: NSObject {
    weak var viewController: UIViewController?
    let barButtonItem: UIBarButtonItem?
    let submissionTypes: UploadTypes?
    let allowsAudio: Bool
    let allowsPhotos: Bool
    let allowsVideo: Bool
    let allowedUploadUTIs: [String]
    let allowedImagePickerControllerMediaTypes: [String]

    public var uploadSelected: NewUpload->() = { _ in }
    public var uploadCanceled: ()->() = { }

    var currentUpload: NewUpload = .None
    
    var currentAction: UploadAction?

    public init(viewController: UIViewController, barButtonItem: UIBarButtonItem?, submissionTypes: UploadTypes?, allowsAudio: Bool, allowsPhotos: Bool, allowsVideo: Bool, allowedUploadUTIs: [String], allowedImagePickerControllerMediaTypes: [String]) {
        self.viewController = viewController
        self.barButtonItem = barButtonItem
        self.submissionTypes = submissionTypes
        self.allowsAudio = allowsAudio
        self.allowsPhotos = allowsPhotos
        self.allowsVideo = allowsVideo
        self.allowedUploadUTIs = allowedUploadUTIs
        self.allowedImagePickerControllerMediaTypes = allowedImagePickerControllerMediaTypes
    }
    
    public func beginUpload() {
        let action = actionForCurrentUpload()
        action.initiate()
        currentAction = action
    }
    
    func actionForCurrentUpload() -> UploadAction {
        var dependentActions: [UploadAction] = []
        if case .None = currentUpload {
            if let submissionTypes = submissionTypes {
                if submissionTypes.contains(.Text) {
                    dependentActions.append(TextSubmissionAction(currentSubmission: currentUpload, delegate: self))
                }
                if submissionTypes.contains(.URL) {
                    dependentActions.append(URLSubmissionAction(viewController: viewController, delegate: self))
                }
            }
        }
      
        let photoOrVideoActions = PhotoOrVideoUploadAction.actionsForUpload(viewController, delegate: self, allowedImagePickerControllerMediaTypes: allowedImagePickerControllerMediaTypes, allowsPhotos: allowsPhotos, allowsVideo: allowsVideo)
        dependentActions.appendContentsOf(photoOrVideoActions)
        
        if allowsAudio {
            dependentActions.append(RecordAudioSubmissionAction(viewController: viewController, delegate: self))
        }

        // if we have file upload capabilities, let's take the UIDocumentPicker route
        if allowedUploadUTIs.count > 0 {
            return FileUploadAction(otherActions: dependentActions, currentUpload: currentUpload, allowedUploadUTIs: allowedUploadUTIs, viewController: viewController, presentFromBarButtonItem: barButtonItem, delegate: self)
        }
        
        if dependentActions.count == 1 {
            return dependentActions[0]
        }
        
        return AnythingButFilesUploadAction(actions: dependentActions, viewController: viewController, barButtonItem: barButtonItem, delegate: self)
    }
}

extension UploadBuilder: UploadActionDelegate {
    func actionCancelled() {
        if case .None = currentUpload {
            currentAction = nil
            return
        }
        
        presentNewUploadViewController()
    }
    
    func chooseUpload(newUpload: NewUpload) {
        
        switch newUpload {
        case .URL(_):
            currentUpload = newUpload
            turnInUpload()
            
        case let .FileUpload(newFiles):
            for file in newFiles {
                currentUpload = currentUpload.uploadByAppendingFile(file)
            }
            presentNewUploadViewController()

            
        case let .MediaComment(mediaFile):
            currentUpload = currentUpload.uploadByAppendingFile(mediaFile)
            presentNewUploadViewController()
            
        default:
            currentUpload = newUpload
            presentNewUploadViewController()
        }
    }
}


// MARK: NewUploadViewController

extension UploadBuilder: NewUploadViewControllerDelegate {
    
    func presentNewUploadViewController() {
        if let viewController = viewController {
            let newUploadViewController = NewUploadViewController.presentFromViewController(viewController)
            newUploadViewController.delegate = self
            newUploadViewController.newUpload = currentUpload
        }
    }
    
    
    // delegate methods:
    
    func newUploadCancelled() {
        uploadCanceled()
    }
    
    func turnInUpload() {
        uploadSelected(currentUpload)
    }
    
    func addFileToNewUpload() {
        beginUpload()
    }
    
    func newUploadModified(upload: NewUpload) {
        currentUpload = upload
    }
}

public struct UploadTypes: OptionSetType {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let OnPaper           = UploadTypes(rawValue: 1<<0)
    public static let DiscussionTopic   = UploadTypes(rawValue: 1<<1)
    public static let Quiz              = UploadTypes(rawValue: 1<<2)
    public static let ExternalTool      = UploadTypes(rawValue: 1<<3)
    public static let Text              = UploadTypes(rawValue: 1<<4)
    public static let URL               = UploadTypes(rawValue: 1<<5)
    public static let Upload            = UploadTypes(rawValue: 1<<6)
    public static let MediaRecording    = UploadTypes(rawValue: 1<<7)
    public static let None              = UploadTypes(rawValue: 1<<8)
}


