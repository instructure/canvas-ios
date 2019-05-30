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

import CoreData
import Foundation

public class GetCustomColors: APIUseCase {
    public typealias Model = Color

    public let request = GetCustomColorsRequest()
    public let scope = Scope.all(orderBy: #keyPath(Color.canvasContextID))
    public let cacheKey: String? = "get-custom-colors"

    public init() {}

    public func write(response: APICustomColors?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        Color.save(response, in: client)
    }
}
