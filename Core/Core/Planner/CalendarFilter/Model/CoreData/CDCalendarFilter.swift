//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class CDCalendarFilter: NSManagedObject {
    /// In the parent app we have separate filters for each student.
    @NSManaged public var observedUserId: String?
    /// The list of contexts we can filter to
    @NSManaged public var entries: Set<CDCalendarFilterEntry>
    @NSManaged public private(set) var rawSelectedContexts: [String]

    public var selectedContexts: Set<Context> {
        get {
            Set(rawSelectedContexts.compactMap { Context(canvasContextID: $0) })
        }
        set {
            rawSelectedContexts = newValue.map { $0.canvasContextID }
        }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setupDefaultValues()
    }

    private func setupDefaultValues() {
        rawSelectedContexts = []
    }
}
