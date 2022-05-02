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

struct DocViewerAnnotationPutResponseHandler {
    public enum Outcome {
        case processNextTask
        case pausedOnError
        case finished
    }
    private let annotation: APIDocViewerAnnotation
    private let task: DocViewerAnnotationUploaderQueue.Task
    private let queue: DocViewerAnnotationUploaderQueue
    private weak var docViewerDelegate: DocViewerAnnotationProviderDelegate?

    public init(annotation: APIDocViewerAnnotation, task: DocViewerAnnotationUploaderQueue.Task, queue: DocViewerAnnotationUploaderQueue, docViewerDelegate: DocViewerAnnotationProviderDelegate?) {
        self.annotation = annotation
        self.task = task
        self.queue = queue
        self.docViewerDelegate = docViewerDelegate
    }

    public func handleUploadResponse(receivedAnnotation: APIDocViewerAnnotation?, error: Error?) -> Outcome {
        if receivedAnnotation == nil {
            return handleUploadFailure(error: error)
        } else {
            return handleUploadSuccess()
        }
    }

    private func handleUploadFailure(error: Error?) -> Outcome {
        let willRetryTask = queue.insertTaskIfNecessary(task)

        if willRetryTask {
            performUIUpdate {
                if let error = error as? APIDocViewerError, error == APIDocViewerError.tooBig {
                    self.docViewerDelegate?.annotationDidExceedLimit(annotation: annotation)
                } else {
                    self.docViewerDelegate?.annotationDidFailToSave(error: error ?? APIDocViewerError.noData)
                }
            }

            return .pausedOnError
        } else {
            return .processNextTask
        }
    }

    private func handleUploadSuccess() -> Outcome {
        if queue.queue.isEmpty {
            performUIUpdate {
                self.docViewerDelegate?.annotationSaveStateChanges(saving: false)
            }
            return .finished
        } else {
            return .processNextTask
        }
    }
}
