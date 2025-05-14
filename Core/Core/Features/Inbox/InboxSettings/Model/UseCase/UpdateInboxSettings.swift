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

import Foundation
import CoreData

public class UpdateInboxSettings: APIUseCase {

    public typealias Model = CDInboxSettings
    public typealias Response = APIUpdateInboxSettings

    let inboxSettings: CDInboxSettings

    public init(inboxSettings: CDInboxSettings) {
        self.inboxSettings = inboxSettings
    }

    public var cacheKey: String?

    public var scope: Scope {
        return .all
    }

    public var request: UpdateInboxSettingsRequest { UpdateInboxSettingsRequest(inboxSettings: inboxSettings) }

    public func write(response: APIUpdateInboxSettings?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        let data = APIInboxSettings(data: response.data.updateMyInboxSettings)

        CDInboxSettings.save(data, in: client)
    }
}
