//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public struct FileInfo: Equatable {
    public var url: URL
    public var size: Int64

    public init(url: URL, size: Int64) {
        self.url = url
        self.size = size
    }
}

public class FileUpload: NSManagedObject {
    @NSManaged var contextRaw: String
    @NSManaged public var url: URL
    @NSManaged public var id: String?
    @NSManaged public var size: Int64
    @NSManaged public var bytesSent: Int64
    @NSManaged public var error: String?
    @NSManaged private var taskIDRaw: NSNumber?
    @NSManaged public var backgroundSessionID: String
    @NSManaged public var completed: Bool
    @NSManaged public var fileID: String?
    @NSManaged public var submission: FileSubmission?

    public var target: FileUploadTarget? {
        if let submission = submission {
            return .submission(courseID: submission.assignment.courseID, assignmentID: submission.assignment.id)
        }
        switch context.contextType {
        case .course:
            return .course(context.id)
        case .user:
            return .user(context.id)
        default:
            return nil
        }
    }

    public var context: Context {
        get { return ContextModel(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
    }

    public var taskID: Int? {
        get { return taskIDRaw?.intValue }
        set { taskIDRaw = NSNumber(value: newValue) }
    }
}

extension FileUpload: Scoped {
    public enum ScopeKeys {
        case assignment(String)
        case taskID(backgroundSessionID: String, taskID: Int)
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .assignment(assignmentID):
            return .where(#keyPath(FileUpload.submission.assignment.id), equals: assignmentID)
        case let .taskID(backgroundSessionID: backgroundSessionID, taskID: taskID):
            let session = NSPredicate(format: "%K == %@", #keyPath(FileUpload.backgroundSessionID), backgroundSessionID)
            let task = NSPredicate(format: "%K == %d", #keyPath(FileUpload.taskIDRaw), taskID)
            let pred = NSCompoundPredicate(andPredicateWithSubpredicates: [session, task])
            return Scope(predicate: pred, order: [])
        }
    }
}
