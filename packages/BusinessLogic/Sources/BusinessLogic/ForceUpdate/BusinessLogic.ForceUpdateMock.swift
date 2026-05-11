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

#if DEBUG

extension BusinessLogic {
    public final class ForceUpdateMock: ForceUpdate {
        public var shouldForceUpdateReturnValue = false
        public private(set) var shouldForceUpdateReceivedInvocations: [(
            appVersion: String?,
            systemVersion: String,
            minimumSystemVersion: String,
            belowAppVersion: String
        )] = []

        public init(shouldForceUpdateReturnValue: Bool = false) {
            self.shouldForceUpdateReturnValue = shouldForceUpdateReturnValue
        }

        public func shouldForceUpdate(
            appVersion: String?,
            systemVersion: String,
            minimumSystemVersion: String,
            belowAppVersion: String
        ) -> Bool {
            shouldForceUpdateReceivedInvocations.append((appVersion, systemVersion, minimumSystemVersion, belowAppVersion))
            return shouldForceUpdateReturnValue
        }
    }
}

#endif
