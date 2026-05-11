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

import Foundation

extension BusinessLogic {
    public protocol ForceUpdate {
        func shouldForceUpdate(
            appVersion: String?,
            systemVersion: String,
            minimumSystemVersion: String,
            belowAppVersion: String
        ) -> Bool
    }

    public struct ForceUpdateLive: ForceUpdate, Sendable {
        public init() {}

        public func shouldForceUpdate(
            appVersion: String?,
            systemVersion: String,
            minimumSystemVersion: String,
            belowAppVersion: String
        ) -> Bool {
            guard let appVersion else { return false }
            return systemVersion.compare(minimumSystemVersion, options: .numeric) != .orderedAscending
                && appVersion.compare(belowAppVersion, options: .numeric) == .orderedAscending
        }
    }
}

extension BusinessLogic.ForceUpdate where Self == BusinessLogic.ForceUpdateLive {
    public static var live: BusinessLogic.ForceUpdateLive { .init() }
}
