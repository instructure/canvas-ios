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
import Photos
import MobileCoreServices

class PhotoOrVideoUploadAction: NSObject, UploadAction, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let title: String
    let icon: UIImage
    let sourceType: UIImagePickerControllerSourceType
    let mediaTypes: [String]
    
    weak var viewController: UIViewController?
    weak var delegate: UploadActionDelegate?
    
    init(title: String, icon: UIImage, sourceType: UIImagePickerControllerSourceType, mediaTypes: [String], viewController: UIViewController?, delegate: UploadActionDelegate) {
        self.title = title
        self.icon = icon
        self.sourceType = sourceType
        self.mediaTypes = mediaTypes
        self.viewController = viewController
        self.delegate = delegate
    }
    
    func initiate() {
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.modalPresentationStyle = .pageSheet
        }
        
        viewController?.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var upload = NewUpload.none
        
        if let
            assetURL = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
                
            upload = .fileUpload([.cameraRollAsset(asset)])
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            upload = .fileUpload([.photo(image)])
        } else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            upload = .mediaComment(.videoURL(videoURL))
        }
        viewController?.dismiss(animated: true) {
            self.delegate?.chooseUpload(upload)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController?.dismiss(animated: true) {
            self.delegate?.actionCancelled()
        }
    }
}


extension PhotoOrVideoUploadAction {
    static func actionsForUpload(_ viewController: UIViewController?, delegate: UploadActionDelegate, allowedImagePickerControllerMediaTypes: [String], allowsPhotos: Bool, allowsVideo: Bool) -> [UploadAction] {
        
        let mediaTypes = allowedImagePickerControllerMediaTypes
        guard mediaTypes.count > 0 else { return [] }

        let titles = titlesForTakingPhotoOrVideo(allowsPhotos, allowsVideo: allowsVideo)
        return [
            PhotoOrVideoUploadAction(title: titles.choosing, icon: .FileKitImageNamed("icon_cameraroll"), sourceType: .photoLibrary, mediaTypes: mediaTypes, viewController: viewController, delegate: delegate),
            PhotoOrVideoUploadAction(title: titles.taking, icon: .FileKitImageNamed("icon_camera"), sourceType: .camera, mediaTypes: mediaTypes, viewController: viewController, delegate: delegate)
        ]
    }
    
    fileprivate static func titlesForTakingPhotoOrVideo(_ allowsPhotos: Bool, allowsVideo: Bool) -> (taking: String, choosing: String) {
        let titles: (String, String)
        switch (allowsPhotos, allowsVideo) {
        case (true, false):
            titles = (
                taking: NSLocalizedString("Take a Photo", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Take a photo submission choice"),
                choosing: NSLocalizedString("Choose a Photo", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Pick a photo from library")
            )
        case (false, true):
            titles = (
                taking: NSLocalizedString("Take a Video", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Take a video submission choice"),
                choosing: NSLocalizedString("Choose a Video", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Pick a video from library")
            )
        default:
            titles = (
                taking: NSLocalizedString("Take Photo or Video", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Take a photo or video submission choice"),
                choosing: NSLocalizedString("Choose a Photo or Video", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Pick a photo or video")
            )
        }
        
        return titles
    }
}
