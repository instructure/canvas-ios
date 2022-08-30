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

/**
 This class is responsible for requesting a `FileUploadTarget` from the API. A file upload target contains the url where the file
 should be uploaded and few upload parameters. These are written back to the given `FileUploadItem`.
 */
public class FileUploadTargetRequester {
    private let api: API
    private let context: NSManagedObjectContext
    private let fileUploadItemID: NSManagedObjectID

    public init(api: API, context: NSManagedObjectContext, fileUploadItemID: NSManagedObjectID) {
        self.api = api
        self.context = context
        self.fileUploadItemID = fileUploadItemID
    }

    /** The result of the request is also written into the underlying `FileUploadItem` object.  */
    public func requestUploadTarget() -> Future<Void, Error> {
        Future<Void, Error> { self.sendRequest(promise: $0) }
    }

    public func sendRequest(promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let fileItem = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem,
                  let fileSubmission = fileItem.fileSubmission
            else { return }

            let fileSize = fileItem.localFileURL.lookupFileSize()
            let body = PostFileUploadTargetRequest.Body(name: fileItem.localFileURL.lastPathComponent, on_duplicate: .rename, parent_folder_path: nil, size: fileSize)
            let request = PostFileUploadTargetRequest(context: fileSubmission.fileUploadContext, body: body)
            api.makeRequest(request) { [weak self] response, _, error in
                self?.handleResponse(response, error: error, promise: promise)
            }
        }
    }

    private func handleResponse(_ response: FileUploadTarget?, error: Error?, promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let fileItem = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem else { return }

            if let response = response {
                fileItem.uploadError = nil
                fileItem.uploadTarget = response
            } else {
                let validError: Error = error ?? NSError.instructureError(NSLocalizedString("Failed to get file upload target.", comment: ""))
                fileItem.uploadError = validError.localizedDescription
                fileItem.uploadTarget = nil
            }

            try? context.save()

            if let error = fileItem.uploadError {
                promise(.failure(error))
            } else {
                promise(.success(()))
            }
        }
    }
}
