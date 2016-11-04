
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
import Photos
import ReactiveCocoa
import MobileCoreServices

let dateFormatter: NSDateFormatter = {
    let df = NSDateFormatter()
    df.dateStyle = .MediumStyle
    return df
}()

private func MIMEType(fileExtension: String) -> String? {
    if !fileExtension.isEmpty {
        guard let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil) else {
            return nil
        }

        let UTI = UTIRef.takeUnretainedValue()
        UTIRef.release()

        guard let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) else {
            return nil
        }

        let MIMEType = MIMETypeRef.takeUnretainedValue()
        MIMETypeRef.release()
        return MIMEType as String
    }
    return nil
}

public enum NewUploadFile {
    case AudioFile(NSURL)
    case FileURL(NSURL)
    case CameraRollAsset(PHAsset)
    case VideoURL(NSURL)
    case Photo(UIImage)
    case Data(NSData)
    
    public var name: String {
        switch self {
        case .FileURL(let url):
            return url.lastPathComponent ?? ""
        case .CameraRollAsset(let asset):
            let type: String
            switch asset.mediaType {
            case .Video:
                type = "Video"
            default:
                type = "Photo"
            }

            let formattedDate = dateFormatter.stringFromDate(asset.modificationDate ?? NSDate())
            return "\(type) \(formattedDate)"
        case .AudioFile(let url):
            return url.lastPathComponent ?? ""
        case .Photo(_):
            return NSLocalizedString("Photo", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "name for a photo just taken")
        case .VideoURL(_):
            return NSLocalizedString("Video", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "name for a video just taken for upload")
        case .Data(_):
            return NSLocalizedString("Data", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "name for upload data")
        }
    }

    public var contentType: String? {
        switch self {
            case .FileURL(let url): return url.pathExtension.flatMap({ MIMEType($0) }) ?? nil
        case .AudioFile(_):
            return "audio/mp4"
        case .CameraRollAsset(let asset):
            switch asset.mediaType {
            case .Video: return "video/mpeg"
            default: return "image/jpeg"
            }
        case .Photo(_): return "image/jpeg"
        case .VideoURL(_): return "video/mpeg"
        case .Data(_): return "text/plain"
        }
    }
    
    var image: UIImage {
        let size = CGSize(width: 34, height: 34)
        
        switch self {
        case .CameraRollAsset(let asset):
            let options = PHImageRequestOptions()
            options.synchronous = true
            
            var thumb: UIImage = UIImage()
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { image, info in
                if let image = image {
                    thumb = image
                }
            }
            
            return thumb
        case .AudioFile(_):
            return UIImage(named: "icon_audio", inBundle: NSBundle(forClass: UploadBuilder.classForCoder()), compatibleWithTraitCollection: nil)!
        case .Photo(let image):
            return image
        default:
            return UIImage(named: "icon_document", inBundle: NSBundle(forClass: UploadBuilder.classForCoder()), compatibleWithTraitCollection: nil)!
        }
    }

    public func extract(block: NSData?->Void) {
        switch self {
        case .FileURL(let url):
            block(NSData(contentsOfURL: url))
        case .AudioFile(let url):
            block(NSData(contentsOfURL: url))
        case .VideoURL(let url):
            block(NSData(contentsOfURL: url))
        case .Photo(let image):
            block(UIImagePNGRepresentation(image))
        case .CameraRollAsset(let asset):
            let manager = PHCachingImageManager()
            switch asset.mediaType {
            case .Image:
                manager.requestImageDataForAsset(asset, options: nil) { (data, _, _, _) in
                    block(data)
                }
            case .Video:
                manager.requestAVAssetForVideo(asset, options: nil) { asset, audioMix, info in
                    if let asset = asset as? AVURLAsset, data = NSData(contentsOfURL: asset.URL) {
                        block(data)
                    }
                }
            default: block(nil)
            }
        case .Data(let data):
            block(data)
        }
    }
}

public enum NewUpload {
    case None
    case Text(String)
    case URL(NSURL)
    case MediaComment(NewUploadFile)
    case FileUpload([NewUploadFile])

    var fileCount: Int {
        switch self {
        case .FileUpload(let urls):
            return urls.count
        case .MediaComment(_):
            return 1
        default:
            return 0
        }
    }

    func uploadByDeletingFileAtIndex(row: Int) -> NewUpload {
        switch self {
        case .FileUpload(var urls) where row < urls.count:
            urls.removeAtIndex(row)
            return .FileUpload(urls)
        default:
            return self
        }
    }

    func uploadByAppendingFile(file: NewUploadFile) -> NewUpload {
        switch (self, file) {
        case (.FileUpload(var files), _):
            files.append(file)
            return .FileUpload(files)
        case (.MediaComment(let mediaCommentFile), _):
            return .FileUpload([mediaCommentFile, file])
        case (.None, .VideoURL), (.None, .AudioFile):
            return .MediaComment(file)
        case (.None, _):
            return .FileUpload([file])
        default:
            return self
        }
    }
}
