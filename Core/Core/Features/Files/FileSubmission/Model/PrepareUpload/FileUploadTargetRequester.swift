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

    /**
     The result of the request is also written into the underlying `FileUploadItem` object.
     - returns: A `Future` that will fulfill the request. This `Future` keeps the class alive
     so you don't need to keep a strong reference to it.
     */
    public func requestUploadTarget(baseURL: URL? = nil) -> Future<Void, Error> {
        Future<Void, Error> { self.sendRequest(baseURL: baseURL, promise: $0) }
    }

    private func sendRequest(baseURL: URL?, promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let fileItem = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem else {
                promise(.failure(FileSubmissionErrors.CoreData.uploadItemNotFound))
                return
            }

            fileItem.uploadError = nil
            fileItem.uploadTarget = nil
            try? context.saveAndNotify()

            let fileSize = fileItem.localFileURL.lookupFileSize()
            let body = PostFileUploadTargetRequest.Body(name: fileItem.localFileURL.lastPathComponent, on_duplicate: .rename, parent_folder_path: nil, size: fileSize)
            let request = PostFileUploadTargetRequest(context: fileItem.fileSubmission.fileUploadContext, body: body)
            let uploadApi = API(api.loginSession, baseURL: baseURL)
            uploadApi.makeRequest(request) { [self] response, _, error in
                handleResponse(response, error: error, promise: promise)
            }
        }
    }

    private func handleResponse(_ response: FileUploadTarget?, error: Error?, promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let fileItem = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem else {
                promise(.failure(FileSubmissionErrors.CoreData.uploadItemNotFound))
                return
            }

            var result: Result<Void, Error>

            if let response = response {
                fileItem.uploadError = nil
                fileItem.uploadTarget = response
                result = .success(())
            } else {
                let validError: Error = error ?? FileSubmissionErrors.RequestUploadTargetUnknownError()
                fileItem.uploadError = validError.localizedDescription
                fileItem.uploadTarget = nil
                result = .failure(validError)
            }

            do {
                try context.saveAndNotify()
            } catch(let error) {
                fileItem.uploadError = error.localizedDescription
                result = .failure(error)
            }

            promise(result)
        }
    }
}
