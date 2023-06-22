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

// swiftlint:disable force_try
final class CourseSyncEntryProgress: NSManagedObject, Comparable {
    @NSManaged public var id: String
    @NSManaged public var selectionRaw: Data
    @NSManaged public var stateRaw: Data

    var selection: CourseEntrySelection {
        get {
            try! JSONDecoder().decode(CourseEntrySelection.self, from: selectionRaw)
        }
        set {
            selectionRaw = try! JSONEncoder().encode(newValue)
        }
    }

    var state: CourseSyncEntry.State {
        get {
            try! JSONDecoder().decode(CourseSyncEntry.State.self, from: stateRaw)
        }
        set {
            stateRaw = try! JSONEncoder().encode(newValue)
        }
    }

    static func < (lhs: CourseSyncEntryProgress, rhs: CourseSyncEntryProgress) -> Bool {
        lhs.selection < rhs.selection
    }

    @discardableResult
    public static func save(
        id: String,
        selection: CourseEntrySelection,
        state: CourseSyncEntry.State,
        in context: NSManagedObjectContext
    ) -> CourseSyncEntryProgress {
        let dbEntity: CourseSyncEntryProgress = context.first(
            where: #keyPath(CourseSyncEntryProgress.id),
            equals: id
        ) ?? context.insert()

        dbEntity.id = id
        dbEntity.selection = selection
        dbEntity.state = state

        return dbEntity
    }
}
// swiftlint:enable force_try
