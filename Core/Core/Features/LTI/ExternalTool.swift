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

import CoreData

public final class ExternalTool: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var arc: Bool
    @NSManaged public var courseID: String?
    @NSManaged public var url: URL?

    @discardableResult
    public static func save(_ item: APIExternalTool, courseID: String?, in context: NSManagedObjectContext) -> ExternalTool {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(ExternalTool.id), item.id.value)
        let tool: ExternalTool = context.fetch(predicate).first ?? context.insert()
        tool.id = item.id.value
        tool.arc = item.arc
        tool.courseID = courseID
        tool.url = item.url
        return tool
    }
}
