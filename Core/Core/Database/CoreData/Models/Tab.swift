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

public class Tab: NSManagedObject {
    @NSManaged var contextRaw: String
    @NSManaged var hiddenRaw: NSNumber?
    @NSManaged public var htmlURL: URL
    @NSManaged public var id: String
    @NSManaged public var label: String
    @NSManaged public var position: Int
    @NSManaged var typeRaw: String
    @NSManaged var visibilityRaw: String

    public var context: Context {
        get { return ContextModel(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
    }

    public var hidden: Bool? {
        get { return hiddenRaw?.boolValue }
        set { hiddenRaw = NSNumber(value: newValue) }
    }

    public var type: TabType {
        get { return TabType(rawValue: typeRaw) ?? .external }
        set { typeRaw = newValue.rawValue }
    }

    public var visibility: TabVisibility {
        get { return TabVisibility(rawValue: visibilityRaw) ?? .none }
        set { visibilityRaw = newValue.rawValue }
    }
}

extension Tab: Scoped {
    public enum ScopeKeys {
        case context(Context)
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .context(context):
            return .where(#keyPath(Tab.contextRaw), equals: context.canvasContextID, orderBy: #keyPath(Tab.position))
        }
    }
}
