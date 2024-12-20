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

import CoreData
import Foundation

public class GetBrandVariables: APIUseCase {
    public typealias Model = CDBrandVariables
    public struct Response: Codable {
        var brandVars: APIBrandVariables
        var headerImage: Data?
    }

    public let request = GetBrandVariablesRequest()
    public let cacheKey: String? = "brand-variables"
    public let ttl: TimeInterval = 24 * 60 * 60 // 1 day

    public init() {}

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping RequestCallback
    ) {
        environment.api.makeRequest(request) { brandVars, urlResponse, error in
            guard let brandVars else {
                return completionHandler(nil, urlResponse, error)
            }

            let remoteImageData = brandVars.header_image.flatMap { try? Data(contentsOf: $0) }
            let response = Response(brandVars: brandVars, headerImage: remoteImageData)
            completionHandler(response, urlResponse, nil)
        }
    }

    public func write(
        response: Response?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let brandVars = response?.brandVars else {
            return
        }
        CDBrandVariables.save(brandVars, headerImageData: response?.headerImage, in: client)
    }
}
