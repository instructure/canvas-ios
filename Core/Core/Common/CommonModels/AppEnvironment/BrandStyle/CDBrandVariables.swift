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
import UIKit

public final class CDBrandVariables: NSManagedObject {
    /// An `APIBrandVariables` object encoded as JSON.
    @NSManaged public var apiBrandVariablesRaw: String
    @NSManaged public var headerImageRaw: Data?
    @NSManaged public var institutionLogo: URL?

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
        dbEntity.institutionLogo = getInstitutionLogoURL(item.institutionLogo)
        return dbEntity
    }

    public func applyBrandTheme() {
        guard let brandVariables else { return }

        Brand.shared = Brand(
            response: brandVariables,
            headerImage: headerImage,
            institutionLogo: Self.getInstitutionLogoURL(brandVariables.institutionLogo)
        )
    }

    private static func getInstitutionLogoURL(_ url: URL?) -> URL? {
        guard let url else { return nil }

        // If the URL is already absolute (has a scheme), return it as-is
        if url.scheme != nil {
            return url
        }

        // Otherwise, resolve it relative to the base URL
        guard let baseURL = AppEnvironment.shared.currentSession?.baseURL else {
            return nil
        }

        return URL(string: url.absoluteString, relativeTo: baseURL)
    }
}
