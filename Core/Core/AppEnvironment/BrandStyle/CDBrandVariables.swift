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

import CoreData

public final class CDBrandVariables: NSManagedObject {
    /// An `APIBrandVariables` object encoded as JSON.
    @NSManaged public var apiBrandVariablesRaw: String
    @NSManaged public var headerImageRaw: Data?

    public private(set) lazy var brandVariables: APIBrandVariables? = {
        let decoder = JSONDecoder()
        guard let jsonData = apiBrandVariablesRaw.data(using: .utf8) else {
            return nil
        }
        return try? decoder.decode(APIBrandVariables.self, from: jsonData)
    }()

    public private(set) lazy var headerImage: UIImage? = {
        guard let headerImageRaw else { return nil }
        return UIImage(data: headerImageRaw)
    }()

    @discardableResult
    public static func save(
        _ item: APIBrandVariables,
        headerImageData: Data?,
        in context: NSManagedObjectContext
    ) -> CDBrandVariables {
        let json: String = {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(item) {
                return String(data: data, encoding: .utf8) ?? ""
            } else {
                return ""
            }
        }()

        let dbEntity: CDBrandVariables = context.first(scope: .all) ?? context.insert()
        dbEntity.apiBrandVariablesRaw = json
        dbEntity.headerImageRaw = headerImageData
        return dbEntity
    }

    public func applyBrandTheme() {
        guard let brandVariables else { return }

        Brand.shared = Brand(response: brandVariables, headerImage: headerImage)
    }
}
