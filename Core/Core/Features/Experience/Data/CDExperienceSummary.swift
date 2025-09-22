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

public final class CDExperienceSummary: NSManagedObject {
    @NSManaged public var currentAppRaw: String
    @NSManaged public var availableAppsRaw: Set<String>

    public var currentApp: Experience {
        Experience(rawValue: currentAppRaw) ?? .academic
    }

    public var availableApps: [Experience] {
        availableAppsRaw.compactMap { Experience(rawValue: $0) }
    }

    @discardableResult
    static func save(
        _ item: APIExperienceSummary,
        in context: NSManagedObjectContext
    ) -> CDExperienceSummary {
        let entity: CDExperienceSummary = context.fetch(.all).first ?? context.insert()
        entity.currentAppRaw = item.current_app.rawValue
        entity.availableAppsRaw = Set(item.available_apps.map { $0.rawValue })
        return entity
    }

    static func update(
        experience: String,
        in context: NSManagedObjectContext
    ) {
        let entity: CDExperienceSummary? = context.fetch(.all).first
        guard let entity else { return }
        entity.currentAppRaw = experience
    }
}
