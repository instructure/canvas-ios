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

public final class CDBrandVariables: NSManagedObject, WriteableModel {
    /// An `APIBrandVariables` object encoded as JSON.
    @NSManaged public var apiBrandVariables: String

    public private(set) lazy var brandVariables: APIBrandVariables? = {
        let decoder = JSONDecoder()
        guard let jsonData = apiBrandVariables.data(using: .utf8) else {
            return nil
        }
        return try? decoder.decode(APIBrandVariables.self, from: jsonData)
    }()

    @discardableResult
    public static func save(
        _ item: APIBrandVariables,
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
        dbEntity.apiBrandVariables = json
        return dbEntity
    }

    public func applyBrandTheme() {
        guard let brandVariables else { return }

        Brand.shared = Brand(response: brandVariables, baseURL: URL(string: "/")!)
    }
}
