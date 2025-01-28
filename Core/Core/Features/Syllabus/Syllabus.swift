//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import CoreData

public class Syllabus: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var assignments: Set<Assignment>
}

#if DEBUG
extension Syllabus {
    public static func make(courseID: String = "1", in context: NSManagedObjectContext) -> Syllabus {
        let syllabus: Syllabus = context.insert()
        syllabus.courseID = courseID
        // swiftlint:disable:next force_try
        try! context.save()
        return syllabus
    }
}
#endif
