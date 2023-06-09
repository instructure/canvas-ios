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
final class CourseSyncEntryProgress: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var selectionData: Data
    @NSManaged public var stateData: Data

    var selection: CourseEntrySelection {
        get {
            try! JSONDecoder().decode(CourseEntrySelection.self, from: selectionData)
        }
        set {
            selectionData = try! JSONEncoder().encode(newValue)
        }
    }

    var state: CourseSyncEntry.State {
        get {
            try! JSONDecoder().decode(CourseSyncEntry.State.self, from: stateData)
        }
        set {
            stateData = try! JSONEncoder().encode(newValue)
        }
    }
}
// swiftlint:enable force_try
