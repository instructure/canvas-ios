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
    private let queue = DocViewerAnnotationUploaderQueue()
    private let taskLock = NSLock()
    private var currentTask: DocViewerAnnotationUploaderQueue.Task?
    private var pausedOnError = false

    public init(api: API, sessionID: String) {
        self.api = api
        self.sessionID = sessionID
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
            performUpload(annotation: annotation)
        case .delete(let annotationID):
            performDelete(annotationID: annotationID)
        }
    }

    private func performUpload(annotation: APIDocViewerAnnotation) {
        api.makeRequest(PutDocViewerAnnotationRequest(body: annotation, sessionID: sessionID)) { [weak self] updated, _, error in
            self?.handleUploadResponse(annotation: annotation, receivedAnnotation: updated, error: error)
        }
    }

    private func handleUploadResponse(annotation: APIDocViewerAnnotation, receivedAnnotation: APIDocViewerAnnotation?, error: Error?) {
        taskLock.lock()
        defer { taskLock.unlock() }

        if receivedAnnotation == nil {
            pausedOnError = true

            if let currentTask = currentTask {
                queue.insertTask(currentTask)
            }

            currentTask = nil

            performUIUpdate {
                if let error = error as? APIDocViewerError, error == APIDocViewerError.tooBig {
                    self.docViewerDelegate?.annotationDidExceedLimit(annotation: annotation)
                } else {
                    self.docViewerDelegate?.annotationDidFailToSave(error: error ?? APIDocViewerError.noData)
                }
            }
        } else {
            currentTask = nil

            if queue.queue.isEmpty {
                performUIUpdate {
                    self.docViewerDelegate?.annotationSaveStateChanges(saving: false)
                }
            } else {
                processNextTask()
            }
        }
    }

    private func performDelete(annotationID: String) {
        api.makeRequest(DeleteDocViewerAnnotationRequest(annotationID: annotationID, sessionID: sessionID)) { [weak self] _, _, error in
            self?.handleDeleteResponse(error: error)
        }
    }

    private func handleDeleteResponse(error: Error?) {
        taskLock.lock()
        defer { taskLock.unlock() }

        if let error = error {
            pausedOnError = true

            if let currentTask = currentTask {
                queue.insertTask(currentTask)
            }
            currentTask = nil

            performUIUpdate {
                self.docViewerDelegate?.annotationDidFailToSave(error: error)
            }
        } else {
            currentTask = nil

            if queue.queue.isEmpty {
                performUIUpdate {
                    self.docViewerDelegate?.annotationSaveStateChanges(saving: false)
                }
            } else {
                processNextTask()
            }
        }
    }
}
