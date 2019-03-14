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
    public var size: Int

    public init(url: URL, size: Int) {
        self.url = url
        self.size = size
    }
}

public class FileUpload: NSManagedObject {
    @NSManaged var contextRaw: String?
    @NSManaged public var url: URL
    @NSManaged public var size: Int
    @NSManaged public var bytesSent: Int
    @NSManaged public var error: String?
    @NSManaged public var taskIDRaw: NSNumber?
    @NSManaged public var sessionID: String?
    @NSManaged public var completed: Bool
    @NSManaged public var fileID: String?
    @NSManaged public var userRaw: NSNumber? // KeychainEntry.hashValue

    public var inProgress: Bool {
        return error == nil && !completed
    }

    public var context: FileUploadContext? {
        get { return contextRaw.flatMap(FileUploadContext.init) }
        set { contextRaw = newValue?.rawValue }
    }

    public var taskID: Int? {
        get { return taskIDRaw?.intValue }
        set { taskIDRaw = NSNumber(value: newValue) }
    }

    public var user: Int? {
        get { return userRaw?.intValue }
        set { userRaw = NSNumber(value: newValue) }
    }

    public func reset() {
        bytesSent = 0
        error = nil
        taskID = nil
        sessionID = nil
        completed = false
        fileID = nil
    }
}
