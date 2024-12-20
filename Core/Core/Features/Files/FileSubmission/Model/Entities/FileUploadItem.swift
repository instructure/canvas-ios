//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import CoreData
import SwiftUI
import UniformTypeIdentifiers

/**
 This entity contains the information of a single file that is part of a file submission.
 */
public final class FileUploadItem: NSManagedObject {
    /** The url pointing to the file we want to upload on the user's device. */
    @NSManaged public var localFileURL: URL
    @NSManaged public var fileSize: Int
    /** The `FileSubmission` CoreData object containing this item. */
    @NSManaged public var fileSubmission: FileSubmission

    // MARK: Upload Step 1: Getting the upload url and parameters

    @NSManaged public var uploadTarget: FileUploadTarget?

    // MARK: Upload Step 2: Uploading binary

    /** The number of bytes uploaded to the server. Continuously updated during upload. */
    @NSManaged public var bytesUploaded: Int
    /** The expected number of  bytes to be uploaded to finish the file upload. This can change during the upload process. */
    @NSManaged public var bytesToUpload: Int
    /** The file ID assigned by the API to this file after the file has been uploaded. Nil means that the file is yet to be uploaded. */
    @NSManaged public var apiID: String?

    // MARK: Upload Step All: Error

    /** The description of the error happened during upload. */
    @NSManaged public var uploadError: String?
}

public extension FileUploadItem {
    enum State: Equatable {
        case waiting
        case readyForUpload
        case uploading(progress: CGFloat)
        case uploaded
        case error(description: String)
    }

    /** From 0.0 to 1.0. */
    var uploadProgress: CGFloat {
        guard bytesToUpload > 0, bytesUploaded >= 0 else { return 0 }
        return min(CGFloat(bytesUploaded) / CGFloat(bytesToUpload), 1.0)
    }

    var state: State {
        if apiID != nil {
            return .uploaded
        } else if let uploadError = uploadError {
            return .error(description: uploadError)
        } else if bytesUploaded > 0 {
            return .uploading(progress: uploadProgress)
        } else if uploadTarget != nil {
            return .readyForUpload
        } else {
            return .waiting
        }
    }

    var stateChangePublisher: AnyPublisher<Void, Never> {
        Publishers.MergeMany([
            publisher(for: \.apiID).map { _ in }.eraseToAnyPublisher(),
            publisher(for: \.uploadError).map { _ in }.eraseToAnyPublisher(),
            publisher(for: \.bytesUploaded).map { _ in }.eraseToAnyPublisher(),
            publisher(for: \.bytesToUpload).map { _ in }.eraseToAnyPublisher()
        ])
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    enum MimeClass {
        case image, audio, video, pdf, doc

        var image: Image {
            switch self {
            case .image: return Image.imageLine
            case .audio: return Image.audioLine
            case .video: return Image.videoLine
            case .pdf: return Image.pdfLine
            case .doc: return Image.documentLine
            }
        }
    }

    var mimeClass: MimeClass {
        let mimeType = localFileURL.mimeType()
        if mimeType.hasPrefix("image/") {
            return .image
        } else if mimeType.hasPrefix("audio/") {
            return .audio
        } else if mimeType.hasPrefix("video/") {
            return .video
        } else if mimeType.hasPrefix("application/pdf") {
            return .pdf
        } else {
            return .doc
        }
    }
}
