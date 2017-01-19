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

public enum NewUploadFile {
    case audioFile(URL)
    case fileURL(URL)
    case cameraRollAsset(PHAsset)
    case videoURL(URL)
    case photo(UIImage)
    case data(Data)
    
    public var name: String {
        switch self {
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
        switch self {
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
    
    var image: UIImage {
        let size = CGSize(width: 34, height: 34)
        
        switch self {
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
            return UIImage(named: "icon_audio", in: Bundle(for: UploadBuilder.classForCoder()), compatibleWith: nil)!
        case .photo(let image):
            return image
        default:
            return UIImage(named: "icon_document", in: Bundle(for: UploadBuilder.classForCoder()), compatibleWith: nil)!
        }
    }

    public var extractDataProducer: SignalProducer<Data?, NSError> {
        return SignalProducer() { observer, disposable in
            do {
                switch self {
                case .fileURL(let url):
                    observer.send(value: try Data(contentsOf: url))
                case .audioFile(let url):
                    observer.send(value: try Data(contentsOf: url))
                case .videoURL(let url):
                    observer.send(value: try Data(contentsOf: url))
                case .photo(let image):
                    observer.send(value: UIImagePNGRepresentation(image))
                case .cameraRollAsset(let asset):
                    let manager = PHCachingImageManager()
                    switch asset.mediaType {
                    case .image:
                        manager.requestImageData(for: asset, options: nil) { (data, _, _, _) in
                            observer.send(value: data)
                        }
                    case .video:
                        manager.requestAVAsset(forVideo: asset, options: nil) { asset, audioMix, info in
                            if let asset = asset as? AVURLAsset, let data = try? Data(contentsOf: asset.url) {
                                observer.send(value: data)
                            }
                        }
                    default: observer.send(value: nil)
                    }
                case .data(let data):
                    observer.send(value: data)
                }
            } catch let e as NSError {
                observer.send(error: e)
            }
        }
    }
}

public enum NewUpload {
    case none
    case text(String)
    case url(Foundation.URL)
    case mediaComment(NewUploadFile)
    case fileUpload([NewUploadFile])

    var fileCount: Int {
        switch self {
        case .fileUpload(let urls):
            return urls.count
        case .mediaComment(_):
            return 1
        default:
            return 0
        }
    }

    func uploadByDeletingFileAtIndex(_ row: Int) -> NewUpload {
        switch self {
        case .fileUpload(var urls) where row < urls.count:
            urls.remove(at: row)
            return .fileUpload(urls)
        default:
            return self
        }
    }

    func uploadByAppendingFile(_ file: NewUploadFile) -> NewUpload {
        switch (self, file) {
        case (.fileUpload(var files), _):
            files.append(file)
            return .fileUpload(files)
        case (.mediaComment(let mediaCommentFile), _):
            return .fileUpload([mediaCommentFile, file])
        case (.none, .videoURL), (.none, .audioFile):
            return .mediaComment(file)
        case (.none, _):
            return .fileUpload([file])
        default:
            return self
        }
    }
}
