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

public class Tab: NSManagedObject {
    @NSManaged var contextRaw: String
    @NSManaged var hiddenRaw: NSNumber?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var fullURL: URL?
    @NSManaged public var url: URL?
    @NSManaged public var id: String
    @NSManaged public var label: String
    @NSManaged public var position: Int
    @NSManaged var typeRaw: String
    @NSManaged var visibilityRaw: String

    public var context: Context {
        get { return Context(canvasContextID: contextRaw) ?? .currentUser }
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

    public var apiBaseURL: URL? {
        return fullURL?.apiBaseURL
    }

    public var name: TabName {
        TabName(rawValue: id) ?? .custom
    }

    func save(_ item: APITab, in client: NSManagedObjectContext, context: Context) {
        id = item.id.value
        htmlURL = item.html_url
        fullURL = item.full_url
        url = item.url
        label = item.label
        position = item.position
        self.context = context
        type = item.type
        visibility = TabVisibility(rawValue: item.visibility) ?? .none
        hidden = item.hidden
    }
}
