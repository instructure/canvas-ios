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
import Result

private let dataErrorMessage = NSLocalizedString("Something went wrong. Check the file format and try again.",
                                         tableName: "Localizable",
                                         bundle: .core,
                                         value: "",
                                         comment: "Error message displayed when the file is unrecognized.")
let dataError = NSError(subdomain: "FileKit", description: dataErrorMessage)

let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

internal func MIMEType(_ fileExtension: String) -> String? {
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
    case videoURL(URL)
    case photo(UIImage)
    case data(Data)
}

@objc public protocol Uploadable {
    var name: String { get }
    var contentType: String? { get }
    var image: UIImage { get }
    var data: Data { get }
}

public class Asset: Uploadable {
    public let name: String
    public let contentType: String?
    public let data: Data
    public let image: UIImage

    public static func fromCameraRoll(asset: PHAsset, handler: @escaping (Result<Asset, NSError>) -> Void) {
        let manager = PHCachingImageManager()
        switch asset.mediaType {
        case .image:
            manager.requestImageData(for: asset, options: nil) { data, uti, _, info in
                guard
                    let data = data,
                    let path = info?["PHImageFileSandboxExtensionTokenKey"] as? String
                    else {
                        handler(Result(error: dataError))
                        return
                }

                let url = URL(fileURLWithPath: path)
                let name = url.lastPathComponent
                let contentType = MIMEType(url.pathExtension)

                requestImage(for: asset) { result in
                    guard let image = result.value else {
                        handler(Result(error: result.error ?? dataError))
                        return
                    }

                    let asset = Asset(name: name, data: data, contentType: contentType, image: image)
                    handler(Result(value: asset))
                }
            }
        case .video:
            manager.requestAVAsset(forVideo: asset, options: nil) { avAsset, audioMix, info in
                guard let videoAsset = avAsset as? AVURLAsset, let data = try? Data(contentsOf: videoAsset.url) else {
                    handler(Result(error: dataError))
                    return
                }

                let name = videoAsset.url.lastPathComponent
                let contentType = "video/mpeg"

                requestImage(for: asset) { result in
                    guard let image = result.value else {
                        handler(Result(error: result.error ?? dataError))
                        return
                    }

                    let asset = Asset(name: name, data: data, contentType: contentType, image: image)
                    handler(Result(value: asset))
                }
            }
        default:
            handler(Result(error: dataError))
            break
        }
    }

    private static func requestImage(for asset: PHAsset, handler: @escaping (Result<UIImage, NSError>)->Void) {
        let size = CGSize(width: 34, height: 34)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: options) { image, _ in
            guard let image = image else {
                handler(Result(error: dataError))
                return
            }
            handler(Result(value: image))
        }
    }

    private init(name: String, data: Data, contentType: String?, image: UIImage) {
        self.name = name
        self.data = data
        self.contentType = contentType
        self.image = image
    }
}

public class NewFileUpload: Uploadable {
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
        case .audioFile(let url):
            return url.lastPathComponent
        case .photo(_):
            return NSLocalizedString("Photo", tableName: "Localizable", bundle: .core, value: "", comment: "name for a photo just taken")
        case .videoURL(let url):
            return url.lastPathComponent
        case .data(_):
            return NSLocalizedString("Data", tableName: "Localizable", bundle: .core, value: "", comment: "name for upload data")
        }
    }

    public var contentType: String? {
        switch kind {
        case .fileURL(let url): return MIMEType(url.pathExtension)
        case .audioFile(_):
            return "audio/mp4"
        case .photo(_): return "image/jpeg"
        case .videoURL(_): return "video/mpeg"
        case .data(_): return "text/plain"
        }
    }

    public var image: UIImage {
        switch kind {
        case .audioFile(_):
            return UIImage(named: "icon_audio", in: .core, compatibleWith: nil)!
        case .photo(let image):
            return image
        default:
            return UIImage(named: "icon_document", in: .core, compatibleWith: nil)!
        }
    }
}
