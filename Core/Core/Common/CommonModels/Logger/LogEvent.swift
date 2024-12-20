//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class LogEvent: NSManagedObject {
    @NSManaged public var timestamp: Date?
    @NSManaged public var typeRaw: String
    @NSManaged public var message: String
}

extension LogEvent {
    public static func scope(forType type: LoggableType?) -> Scope {
        guard let type = type else {
            let order = NSSortDescriptor(key: #keyPath(LogEvent.timestamp), ascending: false)
            return Scope(predicate: .all, order: [order])
        }
        return Scope.where(#keyPath(LogEvent.typeRaw), equals: type.rawValue)
    }
}
