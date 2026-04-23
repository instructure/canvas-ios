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

import Snapshots
import CoreData

extension AsyncStore where U.Model: Detachable, U.Model.Snapshot.Model == U.Model {
    public typealias Snapshot = U.Model.Snapshot

    /// ​Convenience overload that uses Snapshot.init as the converter.
    /// ​- SeeAlso: getEntities(convert:ignoreCache:loadAllPages:)
    public func getEntities(ignoreCache: Bool = false, loadAllPages: Bool = true) async throws -> [Snapshot] {
        try await getEntities(convert: Snapshot.init, ignoreCache: ignoreCache, loadAllPages: loadAllPages)
    }

    /// ​Convenience overload that uses Snapshot.init as the converter.
    /// ​- SeeAlso: getSingleEntity(convert:ignoreCache:loadAllPages:)
    public func getSingleEntity(
        ignoreCache: Bool = false,
        loadAllPages: Bool = true,
        assertOnlyOneEntityFound: Bool = true
    ) async throws -> Snapshot {
        try await getSingleEntity(
            convert: Snapshot.init,
            ignoreCache: ignoreCache,
            loadAllPages: loadAllPages,
            assertOnlyOneEntityFound: assertOnlyOneEntityFound
        )
    }

    /// ​Convenience overload that uses Snapshot.init as the converter.
    /// ​- SeeAlso: getEntitiesFromDatabase(convert:)
    public func getEntitiesFromDatabase() async throws -> [Snapshot] {
        try await getEntitiesFromDatabase(convert: Snapshot.init)
    }

    /// ​Convenience overload that uses Snapshot.init as the converter.
    /// ​- SeeAlso: streamEntities(convert:ignoreCache:loadAllPages:)
    public func streamEntities(ignoreCache: Bool = false, loadAllPages: Bool = true) async throws -> AsyncThrowingStream<[Snapshot], Error> {
        try await streamEntities(convert: Snapshot.init, ignoreCache: ignoreCache, loadAllPages: loadAllPages)
    }
}
