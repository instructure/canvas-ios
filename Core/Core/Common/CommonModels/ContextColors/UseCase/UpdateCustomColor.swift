//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct UpdateCustomColor: APIUseCase {
    typealias Model = ContextColor

    let context: Context
    let color: String

    var cacheKey: String? { nil }
    var request: PutCustomColorRequest { PutCustomColorRequest(context: context, color: color) }

    func write(response: PutCustomColorRequest.Body?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let color = response?.hexcode else { return }
        ContextColor.save(APICustomColors(custom_colors: [ context.canvasContextID: color ]), in: client)
    }
}
