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

class DocViewerAnnotationUploader {
    public weak var docViewerDelegate: DocViewerAnnotationProviderDelegate?

    private let api: API
    private let sessionID: String
    private let queue: DocViewerAnnotationUploaderQueue
    private let taskLock = NSRecursiveLock()
    private var currentTask: DocViewerAnnotationUploaderQueue.Task?
    private var pausedOnError = false

    public init(api: API, sessionID: String, queue: DocViewerAnnotationUploaderQueue = DocViewerAnnotationUploaderQueue()) {
        self.api = api
        self.sessionID = sessionID
        self.queue = queue
    }

    public func save(_ annotation: APIDocViewerAnnotation) {
        taskLock.lock()
        defer { taskLock.unlock() }

        queue.put(annotation)
        pausedOnError = false
        processNextTask()
    }

    public func delete(annotationID: String) {
        taskLock.lock()
        defer { taskLock.unlock() }

        queue.delete(annotationID)
        pausedOnError = false
        processNextTask()
    }

    public func retryFailedRequest() {
        taskLock.lock()
        defer { taskLock.unlock() }

        pausedOnError = false
        processNextTask()
    }

    private func processNextTask() {
        guard currentTask == nil, !pausedOnError, let task = queue.requestTask() else {
            return
        }

        self.currentTask = task

        performUIUpdate {
            self.docViewerDelegate?.annotationSaveStateChanges(saving: true)
        }

        switch task {
        case .put(let annotation):
            let request = PutDocViewerAnnotationRequest(body: annotation, sessionID: sessionID)
            let handler = DocViewerAnnotationPutResponseHandler(annotation: annotation, task: task, queue: queue, docViewerDelegate: docViewerDelegate)
            performRequest(request, handler: handler)
        case .delete(let annotationID):
            let request = DeleteDocViewerAnnotationRequest(annotationID: annotationID, sessionID: sessionID)
            let handler = DocViewerAnnotationDeleteResponseHandler(task: task, queue: queue, docViewerDelegate: docViewerDelegate)
            performRequest(request, handler: handler)
        }
    }

    private func performRequest<Request: APIRequestable>(_ request: Request, handler: DocViewerAnnotationUploadResponseHandler) {
        api.makeRequest(request) { [weak self] response, _, error in
            guard let self = self else { return }

            self.taskLock.lock()
            defer { self.taskLock.unlock() }

            let outcome = handler.handleResponse(response, error: error)
            self.currentTask = nil

            switch outcome {
            case .processNextTask:
                self.processNextTask()
            case .pausedOnError:
                self.pausedOnError = true
            case .finished:
                break
            }
        }
    }
}
