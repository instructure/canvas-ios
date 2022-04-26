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

class DocViewerAnnotationUploaderQueue {
    public enum Task: Equatable {
        case put(APIDocViewerAnnotation)
        case delete(annotationID: String)
    }
    public private(set) var queue: [Task] = []
    private var queueLock = NSLock()

    public init() {
    }

    public func put(_ annotation: APIDocViewerAnnotation) {
        queueLock.lock()
        removeTasks(with: annotation.id)
        queue.append(.put(annotation))
        queueLock.unlock()
    }

    public func delete(_ annotationID: String) {
        queueLock.lock()
        removeTasks(with: annotationID)
        queue.append(.delete(annotationID: annotationID))
        queueLock.unlock()
    }

    public func requestTask() -> Task? {
        queueLock.lock()
        defer { queueLock.unlock() }
        return queue.isEmpty ? nil : queue.removeFirst()
    }

    private func removeTasks(with id: String) {
        queue = queue.filter { task in
            switch task {
            case .put(let annotation):
                return annotation.id != id
            case .delete(let annotationID):
                return annotationID != id
            }
        }
    }
}
