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
import ReactiveSwift
import Result

class PhotoOrVideoUploadAction: NSObject, FileUploadAction, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: FileUploadActionDelegate?
    let title: String
    let icon: UIImage

    let sourceType: UIImagePickerControllerSourceType
    let mediaTypes: [String]

    init(title: String, icon: UIImage, sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        self.title = title
        self.icon = icon
        self.sourceType = sourceType
        self.mediaTypes = mediaTypes
    }

    func initiate() {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.modalPresentationStyle = .pageSheet
        }

        delegate?.fileUploadAction(self, wantsToPresent: picker)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let assetURL = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
                let manager = PHCachingImageManager()
                switch asset.mediaType {
                case .image:
                    manager.requestImageData(for: asset, options: nil) { [weak self] (data, _, _, _) in
                        guard let me = self else { return }
                        guard let data = data else {
                            me.pickerDataFailure(picker)
                            return
                        }
                        let uploadable = NewFileUpload(kind: .cameraRollAsset(asset), data: data)
                        me.picker(picker, finishedWith: uploadable)
                    }
                case .video:
                    manager.requestAVAsset(forVideo: asset, options: nil) { [weak self] avAsset, audioMix, info in
                        guard let me = self else { return }
                        if let videoAsset = avAsset as? AVURLAsset {
                            if let data = try? Data(contentsOf: videoAsset.url) {
                                let uploadable = NewFileUpload(kind: .cameraRollAsset(asset), data: data)
                                me.picker(picker, finishedWith: uploadable)
                            } else {
                                me.pickerDataFailure(picker)
                            }
                        } else {
                            me.pickerDataFailure(picker)
                        }
                    }
                default:
                    self.pickerDataFailure(picker)
                }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let data = UIImagePNGRepresentation(image) {
            let uploadable = NewFileUpload(kind: .photo(image), data: data)
            self.picker(picker, finishedWith: uploadable)
        } else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL, let data = try? Data(contentsOf: videoURL) {
            let uploadable = NewFileUpload(kind: .videoURL(videoURL), data: data)
            self.picker(picker, finishedWith: uploadable)
        } else {
            self.pickerDataFailure(picker)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.delegate?.fileUploadActionDidCancel(self)
        }
    }

    private func pickerDataFailure(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.delegate?.fileUploadActionFailedToConvertData(self)
        }
    }

    private func picker(_ picker: UIImagePickerController, finishedWith uploadable: Uploadable) {
        picker.dismiss(animated: true) {
            self.delegate?.fileUploadAction(self, finishedWith: uploadable)
        }
    }
}


extension PhotoOrVideoUploadAction {
    static func actionsForUpload(allowsPhotos: Bool, allowsVideo: Bool) -> (choosing: PhotoOrVideoUploadAction, taking: PhotoOrVideoUploadAction)? {
        
        let titles = titlesForTakingPhotoOrVideo(allowsPhotos: allowsPhotos, allowsVideo: allowsVideo)

        let mediaTypes = (allowsPhotos ? [kUTTypeImage as String] : []) + (allowsVideo ? [kUTTypeMovie as String] : [])
        guard mediaTypes.any() else {
            return nil
        }

        return (
            PhotoOrVideoUploadAction(title: titles.choosing, icon: .FileKitImageNamed("icon_cameraroll"), sourceType: .photoLibrary, mediaTypes: mediaTypes),
            PhotoOrVideoUploadAction(title: titles.taking, icon: .FileKitImageNamed("icon_camera"), sourceType: .camera, mediaTypes: mediaTypes)
        )
    }
    
    private static func titlesForTakingPhotoOrVideo(allowsPhotos: Bool, allowsVideo: Bool) -> (taking: String, choosing: String) {
        let titles: (String, String)
        switch (allowsPhotos, allowsVideo) {
        case (true, false):
            titles = (
                taking: NSLocalizedString("Take a Photo", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Take a photo submission choice"),
                choosing: NSLocalizedString("Choose a Photo", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Pick a photo from library")
            )
        case (false, true):
            titles = (
                taking: NSLocalizedString("Take a Video", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Take a video submission choice"),
                choosing: NSLocalizedString("Choose a Video", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Pick a video from library")
            )
        default:
            titles = (
                taking: NSLocalizedString("Take Photo or Video", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Take a photo or video submission choice"),
                choosing: NSLocalizedString("Choose a Photo or Video", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Pick a photo or video")
            )
        }
        
        return titles
    }
}
