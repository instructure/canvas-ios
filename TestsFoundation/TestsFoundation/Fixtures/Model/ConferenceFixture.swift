//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

extension Conference {
    @discardableResult
    public static func make(
        from api: APIConference = .make(),
        context: Context = Context(.course, id: "1"),
        in client: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> Conference {
        let model = Conference.save(api, in: client, context: context)
        try! client.save()
        return model
    }
}

extension ConferenceRecording {
    @discardableResult
    public static func make(
        from api: APIConferenceRecording = .make(),
        in client: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> ConferenceRecording {
        let model = ConferenceRecording.save(api, in: client)
        try! client.save()
        return model
    }
}
