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

public final class GradingSchemeEntry: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var value: Double
    @NSManaged public var course: Course?
}

extension GradingSchemeEntry: WriteableModel {

    @discardableResult
    public static func save(_ item: APIGradingSchemeEntry, in context: NSManagedObjectContext) -> GradingSchemeEntry {
        let gradingSchemeEntry: GradingSchemeEntry = context.insert()
        gradingSchemeEntry.name = item.name
        gradingSchemeEntry.value = item.value
        return gradingSchemeEntry
    }
}

extension Sequence where Element == GradingSchemeEntry {

    func convertScoreToLetterGrade(score: Double) -> String? {
        first { score >= $0.value }?.name
    }
}
