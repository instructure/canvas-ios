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
import ReactiveSwift
import MobileCoreServices

let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

private func MIMEType(_ fileExtension: String) -> String? {
    if !fileExtension.isEmpty {
        guard let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil) else {
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

public enum UploadType {
    case audioFile(URL)
    case fileURL(URL)
    case cameraRollAsset(PHAsset)
    case videoURL(URL)
    case photo(UIImage)
    case data(Data)
}

public protocol Uploadable {
    var name: String { get }
    var contentType: String? { get }
    var image: UIImage { get }
    var data: Data { get }
}

public struct NewFileUpload: Uploadable {
    public let kind: UploadType
    public let data: Data

    public init(kind: UploadType, data: Data) {
        self.kind = kind
        self.data = data
    }

    public var name: String {
        switch kind {
        case .fileURL(let url):
            return url.lastPathComponent
        case .cameraRollAsset(let asset):
            let type: String
            switch asset.mediaType {
            case .video:
                type = "Video"
            default:
                type = "Photo"
            }

            let formattedDate = dateFormatter.string(from: asset.modificationDate ?? Date())
            return "\(type) \(formattedDate)"
        case .audioFile(let url):
            return url.lastPathComponent
        case .photo(_):
            return NSLocalizedString("Photo", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "name for a photo just taken")
        case .videoURL(_):
            return NSLocalizedString("Video", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "name for a video just taken for upload")
        case .data(_):
            return NSLocalizedString("Data", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "name for upload data")
        }
    }

    public var contentType: String? {
        switch kind {
        case .fileURL(let url): return MIMEType(url.pathExtension)
        case .audioFile(_):
            return "audio/mp4"
        case .cameraRollAsset(let asset):
            switch asset.mediaType {
            case .video: return "video/mpeg"
            default: return "image/jpeg"
            }
        case .photo(_): return "image/jpeg"
        case .videoURL(_): return "video/mpeg"
        case .data(_): return "text/plain"
        }
    }

    public var image: UIImage {
        let size = CGSize(width: 34, height: 34)
        
        switch kind {
        case .cameraRollAsset(let asset):
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            
            var thumb: UIImage = UIImage()
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: options) { image, info in
                if let image = image {
                    thumb = image
                }
            }
            
            return thumb
        case .audioFile(_):
            return UIImage(named: "icon_audio", in: .fileKit, compatibleWith: nil)!
        case .photo(let image):
            return image
        default:
            return UIImage(named: "icon_document", in: .fileKit, compatibleWith: nil)!
        }
    }
}
