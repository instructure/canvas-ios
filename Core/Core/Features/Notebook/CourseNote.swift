//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public final class CourseNote: NSManagedObject {

    // MARK: - Required

    @NSManaged public var id: String
    @NSManaged public var date: Date
    @NSManaged public var courseID: String

    // MARK: - Optional

    @NSManaged public var content: String?
    @NSManaged public var cursor: String?
    @NSManaged public var highlightedText: String?
    @NSManaged public var highlightKey: String?
    @NSManaged public var labels: String?
    @NSManaged public var length: NSNumber?
    @NSManaged public var startIndex: NSNumber?
    @NSManaged public var hasMore: NSNumber?

    public var labelsList: [String] {
        return labels?.components(separatedBy: ";") ?? []
    }

    public var hasMoreBool: Bool {
        get {
            return hasMore?.boolValue ?? false
        }
        set {
            hasMore = NSNumber(value: newValue)
        }
    }
}
