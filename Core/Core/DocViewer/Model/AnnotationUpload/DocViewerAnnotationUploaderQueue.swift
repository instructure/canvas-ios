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

        public var annotationId: String {
            switch self {
            case .put(let annotation):
                return annotation.id
            case .delete(let annotationID):
                return annotationID
            }
        }
    }
    public private(set) var tasks: [Task] = []

    public init() {
    }

    public func put(_ annotation: APIDocViewerAnnotation) {
        removeTasks(with: annotation.id)
        tasks.append(.put(annotation))
    }

    public func delete(_ annotationID: String) {
        removeTasks(with: annotationID)
        tasks.append(.delete(annotationID: annotationID))
    }

    /**
     Inserts the given task to the first place of the queue if there are no other tasks already in the queue for the same annotation ID.
     - returns: True if the task was inserted, false if the queue was left intact.
     */
    @discardableResult
    public func insertTaskIfNecessary(_ task: Task) -> Bool {
        let queueHasTaskForAnnotation = tasks.contains { $0.annotationId == task.annotationId }

        if queueHasTaskForAnnotation {
            return false
        } else {
            tasks.insert(task, at: 0)
            return true
        }
    }

    public func requestTask() -> Task? {
        return tasks.isEmpty ? nil : tasks.removeFirst()
    }

    private func removeTasks(with id: String) {
        tasks = tasks.filter { $0.annotationId != id }
    }
}
