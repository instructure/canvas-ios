//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Photos
import ReactiveSwift
import MobileCoreServices

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
