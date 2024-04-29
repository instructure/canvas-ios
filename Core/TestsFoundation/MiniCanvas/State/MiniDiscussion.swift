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

import Foundation
@testable import Core

public class MiniDiscussion {

    // Mutable container
    public class Entry {
        public var api: APIDiscussionEntry
        public var id: String { api.id.value }

        public init(_ api: APIDiscussionEntry) {
            self.api = api
        }
    }

    public var api: APIDiscussionTopic
    public var id: String { api.id.value }
    public var entries: [Entry] = []

    public func view(state: MiniCanvasState) -> APIDiscussionView {
        .make(
            participants: state.allUsers.map(APIDiscussionParticipant.make),
            unread_entries: [],
            entry_ratings: [:],
            forced_entries: [],
            view: entries.map(\.api)
        )
    }

    public static func create(_ topic: APIDiscussionTopic, populatingState state: MiniCanvasState) -> MiniDiscussion {
        MiniDiscussion(topic)
    }

    public init(_ topic: APIDiscussionTopic) {
        self.api = topic
    }
}
