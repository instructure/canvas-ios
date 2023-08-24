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

// TODO: Check if this is required
public final class GradingStandard: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courses: Set<Course>
    @NSManaged public private(set) var gradingSchemeRaw: NSOrderedSet

    public var gradingSchemes: [GradingSchemeEntry] {
        get { gradingSchemeRaw.array as? [GradingSchemeEntry] ?? [] }
        set { gradingSchemeRaw = NSOrderedSet(array: newValue) }
    }
}

extension GradingStandard: WriteableModel {

    @discardableResult
    public static func save(_ item: APIGradingStandard, in context: NSManagedObjectContext) -> GradingStandard {
        let gradingStandard: GradingStandard = context.first(where: #keyPath(GradingStandard.id), equals: item.id) ?? context.insert()
        gradingStandard.id = item.id
        gradingStandard.gradingSchemes = item.grading_scheme.map { GradingSchemeEntry.save($0, in: context) }
        return gradingStandard
    }
}
