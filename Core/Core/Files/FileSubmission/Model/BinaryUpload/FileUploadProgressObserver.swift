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
 This class listens to `URLSessionTask` state updates and writes the upload state to a `FileUploadItem`.
 */
public class FileUploadProgressObserver: NSObject {
    // TODO: Convert this to Future
    /** This publisher is signalled when the upload finishes. At this point either the file's `apiID` or `error` property is non-nil. */
    public private(set) lazy var uploadCompleted: AnyPublisher<Void, Error> = completionSubject.eraseToAnyPublisher()
    public let fileUploadItemID: NSManagedObjectID

    private let context: NSManagedObjectContext
    private let decoder: JSONDecoder
    private let completionSubject = PassthroughSubject<Void, Error>()

    public init(context: NSManagedObjectContext, fileUploadItemID: NSManagedObjectID) {
        self.context = context
        self.fileUploadItemID = fileUploadItemID
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
}

// TODO: Extract these 3 delegate methods into a new protocol
extension FileUploadProgressObserver: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        context.performAndWait {
            guard let item = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem else { return }
            item.bytesUploaded = Int(totalBytesSent)
            item.bytesToUpload = Int(totalBytesExpectedToSend)
            try? context.save()
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        context.performAndWait {
            guard let item = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem else {
                completionSubject.send(completion: .failure(FileSubmissionErrors.CoreData.uploadItemNotFound))
                return
            }

            if item.apiID == nil, error == nil {
                item.uploadError = NSLocalizedString("Session completed without error or file ID.", comment: "")
            } else {
                item.uploadError = error?.localizedDescription
            }

            try? context.save()
            completionSubject.send()
            completionSubject.send(completion: .finished)
        }
    }
}

extension FileUploadProgressObserver: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        context.performAndWait {
            guard let item = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem,
                  let response = try? decoder.decode(APIFile.self, from: data)
            else { return }

            item.apiID = response.id.value
            item.uploadError = nil
            try? context.save()
        }
    }
}
