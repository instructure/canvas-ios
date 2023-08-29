//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import CoreData
import Foundation

final class CourseSyncStateProgress: NSManagedObject, Comparable {
    @NSManaged public var id: String
    @NSManaged private(set) var selectionRaw: Int
    @NSManaged private(set) var stateRaw: Int
    @NSManaged private(set) var entryID: String
    @NSManaged private(set) var tabID: String?
    @NSManaged private(set) var fileID: String?
    @NSManaged private(set) var progress: NSNumber?

    var selection: CourseEntrySelection {
        get {
            switch selectionRaw {
            case 0: return .course(entryID)
            case 1: return .tab(entryID, tabID!)
            case 2: return .file(entryID, fileID!)
            default:
                fatalError("CourseSyncEntryProgress.CourseEntrySelection incorrect data.")
            }
        }
        set {
            switch newValue {
            case let .course(entryID):
                self.entryID = entryID
                selectionRaw = 0
            case let .tab(entryID, tabID):
                self.entryID = entryID
                self.tabID = tabID
                selectionRaw = 1
            case let .file(entryID, fileID):
                self.entryID = entryID
                self.fileID = fileID
                selectionRaw = 2
            }
        }
    }

    var state: CourseSyncEntry.State {
        get {
            switch stateRaw {
            case 0: return .loading(progress?.floatValue)
            case 1: return .error
            case 2: return .downloaded
            default:
                fatalError("CourseSyncEntryProgress.State incorrect data.")
            }
        }
        set {
            switch newValue {
            case let .loading(progress):
                stateRaw = 0
                if let progress {
                    self.progress = NSNumber(value: progress)
                } else {
                    self.progress = nil
                }
            case .error:
                stateRaw = 1
            case .downloaded:
                stateRaw = 2
            }
        }
    }

    static func < (lhs: CourseSyncStateProgress, rhs: CourseSyncStateProgress) -> Bool {
        lhs.selection < rhs.selection
    }

    @discardableResult
    public static func save(
        id: String,
        selection: CourseEntrySelection,
        state: CourseSyncEntry.State,
        in context: NSManagedObjectContext
    ) -> CourseSyncStateProgress {
        let dbEntity: CourseSyncStateProgress = context.first(
            where: #keyPath(CourseSyncStateProgress.id),
            equals: id
        ) ?? context.insert()

        dbEntity.id = id
        dbEntity.selection = selection
        dbEntity.state = state

        return dbEntity
    }
}
