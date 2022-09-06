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
 This class acts as a storage  for `FileUploadProgressObserver` objects. The purpose of this  object is to build up a list of
 `FileUploadProgressObserver`s for each in progress `URLSessionTask`s.  This is required because when the app is launched
 in the background because a background upload is in progress we have no in-memory state of what files are being uploaded.

 Observers are created the following way:
 - This class listens to `URLSessionTask` delegate callbacks.
 - When a callback is received, it inspects if the `URLSessionTask`'s `taskDescription` contains a valid `NSManagedObjectID`.
 - If a `NSManagedObjectID` could be extracted it asks for a `FileUploadProgressObserver` and caches it.
 - `URLSessionTask` delegate callbacks then forwarded to this `FileUploadProgressObserver`.
 */
public class FileUploadProgressObserversCache: NSObject {
    private let context: NSManagedObjectContext
    private let factory: (_ fileSubmissionID: NSManagedObjectID, _ fileUploadItemID: NSManagedObjectID) -> FileUploadProgressObserver
    private var observerCache: [NSManagedObjectID: FileUploadProgressObserver] = [:]

    /**
     - parameters:
        - factory: A block that gets invoked when the cache needs a new FileUploadProgressObserver for the given `FileUploadItem`.
     */
    public init(context: NSManagedObjectContext, factory: @escaping (_ fileSubmissionID: NSManagedObjectID, _ fileUploadItemID: NSManagedObjectID) -> FileUploadProgressObserver) {
        self.context = context
        self.factory = factory
    }

    public func makeObjectID(url stringURL: String?) -> NSManagedObjectID? {
        guard
            let stringURL = stringURL,
            let url = URL(string: stringURL)
        else { return nil }

        return context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    }

    /**
     - returns: The `FileUploadProgressObserver` for the given upload item either from the cache or a newly created instance.
     */
    public func retrieveProgressObserver(fileUploadItemID: NSManagedObjectID) -> FileUploadProgressObserver {
        if let observer = observerCache[fileUploadItemID] {
            return observer
        }

        var fileSubmissionID: NSManagedObjectID!
        context.performAndWait {
            guard let fileItem = try? context.existingObject(with: fileUploadItemID) as? FileUploadItem,
                  let fileSubmission = fileItem.fileSubmission
            else { return } // TODO: If a submission isn't found for the given item we'll crash, make fileSubmission non-optional

            fileSubmissionID = fileSubmission.objectID
        }
        let observer = factory(fileSubmissionID, fileUploadItemID)
        removeObserverOnCompletion(observer)
        observerCache[fileUploadItemID] = observer
        return observer
    }

    private func retrieveProgressObserver(taskID: String?) -> FileUploadProgressObserver? {
        var observer: FileUploadProgressObserver?

        context.performAndWait { [self] in
            guard let managedObjectID = makeObjectID(url: taskID) else { return }
            observer = retrieveProgressObserver(fileUploadItemID: managedObjectID)
        }

        return observer
    }

    private func removeObserverOnCompletion(_ observer: FileUploadProgressObserver) {
        var uploadCompletionSubscription: AnyCancellable?
        uploadCompletionSubscription = observer
            .uploadCompleted
            .sink { [weak self] _ in
                uploadCompletionSubscription?.cancel()
                self?.observerCache[observer.fileUploadItemID] = nil
            } receiveValue: { _ in }
    }
}

extension FileUploadProgressObserversCache: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        retrieveProgressObserver(taskID: task.taskID)?.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        retrieveProgressObserver(taskID: task.taskID)?.urlSession(session, task: task, didCompleteWithError: error)
    }
}

extension FileUploadProgressObserversCache: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        retrieveProgressObserver(taskID: dataTask.taskID)?.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}
