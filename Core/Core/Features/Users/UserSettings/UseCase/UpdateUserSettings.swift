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

public struct UpdateUserSettings: APIUseCase {
    public typealias Model = UserSettings

    public let cacheKey: String? = nil
    public let request: PutUserSettingsRequest
    public let scope = Scope(predicate: .all, order: [])

    public init(hideDashcardColorOverlays: Bool? = nil) {
        request = PutUserSettingsRequest(hide_dashcard_color_overlays: hideDashcardColorOverlays)
    }
}
