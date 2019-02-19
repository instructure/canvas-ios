//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public class LogEvent: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var typeRaw: String
    @NSManaged public var message: String
}

extension LogEvent: Scoped {
    public enum ScopeKeys {
        case all
        case type(LoggableType)
    }

    public static func scope(forName name: LogEvent.ScopeKeys) -> Scope {
        switch name {
        case .all:
            let order = NSSortDescriptor(key: #keyPath(LogEvent.timestamp), ascending: false)
            return Scope(predicate: .all, order: [order])
        case let .type(type):
            return Scope.where(#keyPath(LogEvent.typeRaw), equals: type.rawValue)
        }
    }
}
