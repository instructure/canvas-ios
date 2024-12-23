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

import Foundation
import CoreData

public final class CDEnvironmentSettings: NSManagedObject, WriteableModel {
    @NSManaged public var calendarContextsLimitRaw: NSNumber?

    public var calendarContextsLimit: Int? {
        get { return calendarContextsLimitRaw?.intValue }
        set { calendarContextsLimitRaw = NSNumber(value: newValue) }
    }

    @discardableResult
    public static func save(
        _ apiEntity: GetEnvironmentSettingsRequest.Response,
        in context: NSManagedObjectContext
    ) -> CDEnvironmentSettings {
        let flag: CDEnvironmentSettings = context.fetch(.all).first ?? context.insert()
        flag.calendarContextsLimit = apiEntity.calendar_contexts_limit
        return flag
    }
}
