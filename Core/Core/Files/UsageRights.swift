//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public final class UsageRights: NSManagedObject {
    @NSManaged public var legalCopyright: String?
    @NSManaged public var license: String?
    @NSManaged var useJustificationRaw: String?

    public var useJustification: UseJustification? {
        get { useJustificationRaw.flatMap { UseJustification(rawValue: $0) } }
        set { useJustificationRaw = newValue?.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIUsageRights, to model: UsageRights? = nil, in client: NSManagedObjectContext) -> UsageRights {
        let model = model ?? client.insert()
        model.legalCopyright = item.legal_copyright
        model.license = item.license
        model.useJustification = item.use_justification
        return model
    }
}

public enum UseJustification: String, Codable, CaseIterable {
    case creative_commons, fair_use, own_copyright, public_domain, used_by_permission
}
